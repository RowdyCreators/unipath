from alembic import context

from database import Base, get_engine

# Import model modules here as they are added so autogenerate sees their tables.
target_metadata = Base.metadata


if context.is_offline_mode():
    context.configure(
        url=get_engine().url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()
else:
    engine = get_engine()
    try:
        with engine.connect() as connection:
            context.configure(connection=connection, target_metadata=target_metadata)
            with context.begin_transaction():
                context.run_migrations()
    finally:
        engine.dispose()
