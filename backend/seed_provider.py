from sqlalchemy.orm import Session

from app.db.database import SessionLocal
from app.models import ProviderProfile, User, UserRole
from app.security import hash_password


def seed_provider(
    email: str = "provider@khidma.app",
    phone: str = "+96550009999",
    password: str = "provider123",
):
    db: Session = SessionLocal()
    try:
        user = db.query(User).filter(User.email == email).first()
        if user is None:
            user = User(
                full_name="Provider Test User",
                email=email,
                phone=phone,
                role=UserRole.provider,
                preferred_language="ar",
                password_hash=hash_password(password),
                is_verified=True,
            )
            db.add(user)
            db.flush()
        else:
            user.role = UserRole.provider
            user.is_verified = True
            user.password_hash = hash_password(password)
            if not user.phone:
                user.phone = phone

        profile = db.query(ProviderProfile).filter(ProviderProfile.user_id == user.id).first()
        if profile is None:
            profile = ProviderProfile(
                user_id=user.id,
                company_name="Al Ahmadi Cooling Co.",
                rating_avg=4.8,
                jobs_completed=12,
                coverage_city="Al Ahmadi",
                verification_status="approved",
                is_online=True,
            )
            db.add(profile)
        else:
            profile.coverage_city = "Al Ahmadi"
            profile.verification_status = "approved"
            profile.is_online = True

        db.commit()
        db.refresh(user)
        db.refresh(profile)
        print("Provider seeded successfully")
        print(f"email={user.email}")
        print(f"password={password}")
        print(f"user_id={user.id}")
        print(f"coverage_city={profile.coverage_city}")
        print(f"verification_status={profile.verification_status}")
    finally:
        db.close()


if __name__ == "__main__":
    seed_provider()
