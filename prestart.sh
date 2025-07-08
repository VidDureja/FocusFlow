#!/usr/bin/env bash
echo "Running prestart script: Creating database tables..."
python3 -c 'from app import db, app; app.app_context().push(); db.create_all()' 