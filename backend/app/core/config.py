from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Khidma Pro API"
    app_version: str = "1.0.0"
    debug: bool = False
    environment: str = "development"

    # Kuwait-first MVP launch configuration
    launch_country: str = "Kuwait"
    launch_cities: list[str] = ["Kuwait City", "Al Ahmadi"]

    database_url: str | None = None
    db_host: str = "localhost"
    db_port: int = 5432
    db_name: str = "khidma"
    db_user: str = "khidma"
    db_password: str = "khidma"
    jwt_secret: str = "dev-only-change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    @model_validator(mode="after")
    def validate_security(self):
        if self.environment.lower() == "production" and self.jwt_secret == "dev-only-change-me":
            raise ValueError("jwt_secret must be set via environment in production.")
        if not self.database_url:
            if self.environment.lower() == "development":
                self.database_url = "sqlite:///./khidma.db"
            else:
                self.database_url = (
                    f"postgresql+psycopg2://{self.db_user}:{self.db_password}"
                    f"@{self.db_host}:{self.db_port}/{self.db_name}"
                )
        return self


settings = Settings()
