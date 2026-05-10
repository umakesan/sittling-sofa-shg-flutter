from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_name: str = "Sittilingi SHG Portal API"
    api_v1_prefix: str = "/api/v1"
    database_url: str = "postgresql+psycopg://postgres:postgres@localhost:5432/sittilingi_shg"
    cors_origins: list[str] = ["http://localhost:5173", "http://localhost:5174"]


settings = Settings()
