# backend/services/otp_service.py
# Smart Harvest — OTP Service
# Generates a 6-digit OTP, stores it in Firestore with a 10-minute expiry,
# and delivers it to the user's email via SMTP (e.g., Gmail App Password).

import random
import smtplib
import string
from datetime import datetime, timezone, timedelta
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from config import Config
from database import get_db
from utils.logger import get_logger

logger = get_logger(__name__)

_OTP_COLLECTION = "otp_verifications"
_OTP_EXPIRY_MINUTES = 10


class OtpService:

    # ── Generate & Send ───────────────────────────────────────────────────────

    @staticmethod
    def send_otp(email: str) -> dict:
        """
        Generate a 6-digit OTP, persist it in Firestore, and e-mail it.
        Returns {"message": "...", "expires_in": 600}.
        Raises ValueError / RuntimeError on failure.
        """
        otp = OtpService._generate_otp()
        OtpService._store_otp(email, otp)
        OtpService._send_email(email, otp)
        return {
            "message": "OTP sent successfully.",
            "expires_in": _OTP_EXPIRY_MINUTES * 60,
        }

    # ── Verify ────────────────────────────────────────────────────────────────

    @staticmethod
    def verify_otp(email: str, otp: str) -> dict:
        """
        Verify the OTP for the given email.
        Deletes the document on success so each OTP is single-use.
        Returns {"verified": True} on success.
        Raises ValueError with a user-friendly message on failure.
        """
        db  = get_db()
        ref = db.collection(_OTP_COLLECTION).document(_doc_id(email))
        doc = ref.get()

        if not doc.exists:
            raise ValueError(
                "No OTP was requested for this email. Please request a new one."
            )

        data = doc.to_dict()

        # Check expiry
        expires_at = data.get("expires_at")
        if expires_at and datetime.now(timezone.utc) > expires_at:
            ref.delete()
            raise ValueError(
                "The OTP has expired. Please request a new one."
            )

        # Check code
        if data.get("otp") != otp.strip():
            raise ValueError("Incorrect OTP. Please try again.")

        # Success — delete so it can't be reused
        ref.delete()
        return {"verified": True}

    # ── Internals ─────────────────────────────────────────────────────────────

    @staticmethod
    def _generate_otp() -> str:
        return "".join(random.choices(string.digits, k=6))

    @staticmethod
    def _store_otp(email: str, otp: str) -> None:
        db  = get_db()
        now = datetime.now(timezone.utc)
        db.collection(_OTP_COLLECTION).document(_doc_id(email)).set({
            "email":      email,
            "otp":        otp,
            "created_at": now,
            "expires_at": now + timedelta(minutes=_OTP_EXPIRY_MINUTES),
        })

    @staticmethod
    def _send_email(to_email: str, otp: str) -> None:
        smtp_host     = Config.SMTP_HOST
        smtp_port     = Config.SMTP_PORT
        smtp_user     = Config.SMTP_USER
        smtp_password = Config.SMTP_PASSWORD
        from_email    = Config.SMTP_FROM or smtp_user

        if not smtp_user or not smtp_password:
            logger.warning(
                "SMTP credentials not configured. OTP for %s is: %s",
                to_email, otp,
            )
            # In development, log the OTP so you can still test without SMTP.
            return

        # Build a nicely formatted HTML email
        html_body = f"""
        <!DOCTYPE html>
        <html>
        <body style="font-family: Arial, sans-serif; background:#f5f5f5; margin:0; padding:20px;">
          <div style="max-width:480px; margin:auto; background:#fff;
                      border-radius:12px; padding:32px; box-shadow:0 2px 8px rgba(0,0,0,.1);">
            <div style="text-align:center; margin-bottom:24px;">
              <h2 style="color:#8FB339; margin:0;">Smart Harvest</h2>
              <p style="color:#757575; margin-top:4px;">Email Verification</p>
            </div>
            <p style="color:#212121;">Hello,</p>
            <p style="color:#212121;">
              Thank you for registering with <strong>Smart Harvest</strong>.
              Use the code below to verify your email address.
              This code expires in <strong>{_OTP_EXPIRY_MINUTES} minutes</strong>.
            </p>
            <div style="text-align:center; margin:32px 0;">
              <span style="display:inline-block; background:#8FB339; color:#fff;
                           font-size:32px; font-weight:bold; letter-spacing:12px;
                           padding:16px 32px; border-radius:8px;">
                {otp}
              </span>
            </div>
            <p style="color:#757575; font-size:13px;">
              If you did not request this, please ignore this email.
            </p>
            <hr style="border:none; border-top:1px solid #eee; margin:24px 0;">
            <p style="color:#bdbdbd; font-size:12px; text-align:center;">
              © 2024 Smart Harvest. All rights reserved.
            </p>
          </div>
        </body>
        </html>
        """

        msg = MIMEMultipart("alternative")
        msg["Subject"] = "Smart Harvest — Your Verification Code"
        msg["From"]    = f"Smart Harvest <{from_email}>"
        msg["To"]      = to_email
        msg.attach(MIMEText(html_body, "html"))

        try:
            with smtplib.SMTP(smtp_host, smtp_port, timeout=10) as server:
                server.ehlo()
                server.starttls()
                server.login(smtp_user, smtp_password)
                server.sendmail(from_email, to_email, msg.as_string())
            logger.info("OTP email sent to %s", to_email)
        except Exception as exc:
            logger.error("Failed to send OTP email to %s: %s", to_email, exc)
            raise RuntimeError(
                "Could not send the verification email. "
                "Please check your email address and try again."
            ) from exc


# ── Helpers ───────────────────────────────────────────────────────────────────

def _doc_id(email: str) -> str:
    """Firestore document ID derived from the email (safe characters only)."""
    return email.replace("@", "_at_").replace(".", "_dot_")
