from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Khidma Pro API"
    app_version: str = "1.0.0"
    debug: bool = False

    # Kuwait-first MVP launch configuration
    launch_country: str = "Kuwait"
    launch_cities: list[str] = ["Kuwait City", "Al Ahmadi"]

    database_url: str = "sqlite:///./khidma.db"
    jwt_secret: str = "change-this-in-production"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


settings = Settings()
