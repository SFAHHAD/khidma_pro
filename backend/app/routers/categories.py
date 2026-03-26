from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models import Service, ServiceCategory
from app.schemas import ServiceCategoryOut, ServiceOut

router = APIRouter(prefix="/catalog", tags=["catalog"])


@router.get("/categories", response_model=list[ServiceCategoryOut])
def list_categories(db: Session = Depends(get_db)):
    return db.query(ServiceCategory).filter(ServiceCategory.is_active.is_(True)).all()


@router.get("/services", response_model=list[ServiceOut])
def list_services(category_id: int | None = None, db: Session = Depends(get_db)):
    query = db.query(Service).filter(Service.is_active.is_(True))
    if category_id is not None:
        query = query.filter(Service.category_id == category_id)
    return query.all()
