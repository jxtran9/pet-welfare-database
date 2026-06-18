# Pet Health & Welfare Database

Full-stack database project for tracking pet welfare records, animal intake data, adoption outcomes, and follow-up needs.

This combined repo contains the React frontend, FastAPI backend, MySQL schema and sample data, SQL queries, and final project documentation in one place for portfolio and career use.

## Project Structure

- `pet-welfare-ui/` - React + Vite frontend
- `pet-welfare-backend/` - FastAPI backend using raw SQL through SQLAlchemy
- `pet-welfare-sql/` - MySQL schema, sample data, and query scripts
- `documentation/` - final project report and supporting documents

## Features

- View animal records from the database
- Add and delete animal records through the UI
- Display animal counts by species
- Run welfare follow-up queries with species filtering
- Run adoption statistics queries with state filtering
- Provide a complete SQL schema and sample dataset for local setup

## Tech Stack

- Frontend: React, Vite
- Backend: FastAPI, Python, SQLAlchemy, PyMySQL
- Database: MySQL
- Deployment targets: Vercel frontend, Railway backend/database

## Local Setup

### 1. Create the database

Open `pet-welfare-sql/schema_and_data.sql` in MySQL Workbench and run the full script.

Then use `pet-welfare-sql/queries.sql` for example SELECT, INSERT, UPDATE, DELETE, and analysis queries.

### 2. Run the backend

```bash
cd pet-welfare-backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export DATABASE_URL="mysql+pymysql://<user>:<password>@<host>/<database>"
uvicorn main:app --reload
```

Backend docs will be available at:

```text
http://localhost:8000/docs
```

### 3. Run the frontend

```bash
cd pet-welfare-ui
npm install
npm run dev
```

Frontend will be available at:

```text
http://localhost:5173
```

## API Endpoints

- `GET /health`
- `GET /animals-simple`
- `POST /add-animal`
- `DELETE /delete-animal/{animal_id}`
- `GET /animal-stats`
- `GET /welfare-followups`
- `GET /adoption-stats`

## Notes

- The backend requires `DATABASE_URL` to be set before startup.
- The frontend currently points to a Railway backend URL in `pet-welfare-ui/src/App.jsx`; if that free-tier service is paused or deleted, run the backend locally and update the frontend API base URL for testing.
- SQL files are intentionally tracked in this repo so the database can be recreated from source.

## Optional Portfolio Additions

- Add screenshots of the animal list, add/delete workflow, species summary, welfare follow-up query, and adoption statistics query.
- Add exported ER diagram and relational schema images alongside the final report.
- Add a short note if the live Vercel/Railway demo is unavailable because the services are paused or deleted.
