from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models import ProviderProfile, User
from app.schemas import ProviderOut

router = APIRouter(prefix="/providers", tags=["providers"])


@router.get("", response_model=list[ProviderOut])
def list_providers(city: str = "Kuwait City", db: Session = Depends(get_db)):
    profiles = (
        db.query(ProviderProfile, User)
        .join(User, ProviderProfile.user_id == User.id)
        .filter(ProviderProfile.coverage_city == city)
        .filter(ProviderProfile.verification_status == "approved")
        .all()
    )
    return [
        ProviderOut(
            user_id=user.id,
            full_name=user.full_name,
            company_name=profile.company_name,
            rating_avg=profile.rating_avg,
            jobs_completed=profile.jobs_completed,
            coverage_city=profile.coverage_city,
            verification_status=profile.verification_status,
            is_online=profile.is_online,
        )
        for profile, user in profiles
    ]
