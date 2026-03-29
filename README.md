# 🏥 BeWell – Wearable Health Monitoring System

## Overview

BeWell is a full-stack health monitoring system for doctors and patients.
The project includes:

* a **web frontend** built with React + Vite
* a **backend API** built with Node.js + Express
* a **MySQL database**
* cloud support through **AWS RDS**
* future extensions for mobile integration and wearable sensor data

---

## Project Structure

```txt
BeWell/
├── apps/
│   ├── api/         # Backend API (Node.js + Express)
│   ├── web/         # Frontend (React + Vite)
│   └── mobile/      # Mobile app (planned)
├── database/
│   ├── schema/      # SQL schema files
│   ├── seed/        # Seed data
│   ├── migrations/  # Future DB migrations
│   └── init.sql     # Master DB setup script
├── docs/
├── infra/
├── .gitignore
└── README.md
```

---

## Tech Stack

### Frontend

* React
* Vite
* TypeScript

### Backend

* Node.js
* Express
* MySQL2
* dotenv
* cors

### Database

* MySQL
* AWS RDS

### Tools

* MySQL Workbench
* Postman
* Git / GitHub

---

## Getting Started

## 1. Clone the repository

```bash
git clone <repo-url>
cd BeWell
```

---

## 2. Install dependencies

Because this is a monorepo-like structure, dependencies must be installed separately for the backend and frontend.

### Backend dependencies

```bash
cd apps/api
npm install
```

### Frontend dependencies

```bash
cd ../web
npm install
```

---

## Database Setup

The database can be initialized using the master script:

```txt
database/init.sql
```

### Database file order

The master script runs the SQL files in this order:

```txt
1. schema/001_create_tables.sql
2. seed/001_seed_users.sql
3. seed/002_seed_patients.sql
```

### Run in MySQL Workbench

Connect either to:

* local MySQL
* or AWS RDS

Then run:

```sql
SOURCE database/init.sql;
```

If `SOURCE` does not work in your environment, run the files manually in the same order.

---

## Backend Configuration

Backend code is in:

```txt
apps/api
```

### Required environment file

Create:

```txt
apps/api/.env
```

Example:

```env
PORT=3001

DB_HOST=your-db-host
DB_PORT=3306
DB_NAME=be_well
DB_USER=your-user
DB_PASSWORD=your-password
```

### Start backend

From `apps/api`:

```bash
npm run dev
```

If there is no dev watcher configured, use:

```bash
node src/server.js
```

### Backend default URL

```txt
http://localhost:3001
```

### Useful test endpoints

```txt
GET http://localhost:3001/health
GET http://localhost:3001/api/patients
GET http://localhost:3001/api/patients/1
```

---

## Frontend Configuration

Frontend code is in:

```txt
apps/web
```

This frontend uses **Vite + React + TypeScript**.

### Start frontend

From `apps/web`:

```bash
npm run dev
```

### Frontend default URL

```txt
http://localhost:5173
```

---

## Frontend ↔ Backend Communication

The frontend calls the backend API running on port `3001`.

Example:

```ts
fetch("http://localhost:3001/api/patients")
```

If you want to avoid hardcoding the backend URL, create a frontend environment file.

### Create:

```txt
apps/web/.env
```

Example:

```env
VITE_API_BASE_URL=http://localhost:3001
```

Then in frontend code:

```ts
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;
```

Example usage:

```ts
fetch(`${API_BASE_URL}/api/patients`)
```

---

## Running the Project Locally

Open **2 terminals**.

### Terminal 1 — backend

```bash
cd apps/api
npm install
npm run dev
```

### Terminal 2 — frontend

```bash
cd apps/web
npm install
npm run dev
```

Then open:

```txt
Frontend: http://localhost:5173
Backend:  http://localhost:3001
```

---

## Current API Endpoints

### Patients

* `GET /api/patients`
* `GET /api/patients/:id`
* `POST /api/patients`
* `PUT /api/patients/:id`
* `DELETE /api/patients/:id`

---

## Example Patient JSON for Testing

### POST /api/patients

```json
{
  "doctor_id": 1,
  "email": "new.patient@bewell.com",
  "password_hash": "hashed_password",
  "first_name": "Elena",
  "last_name": "Popa",
  "phone": "0740000000",
  "cnp": "3234567890123",
  "date_of_birth": "1992-06-15",
  "age": 33,
  "gender": "FEMALE",
  "profession": "Accountant",
  "workplace": "Firma XYZ",
  "address": {
    "country": "Romania",
    "county": "Timis",
    "city": "Timisoara",
    "street": "Str. Memoriei",
    "street_number": "15",
    "building": "A",
    "apartment": "12",
    "postal_code": "300100"
  },
  "medical_profile": {
    "medical_history": "Asthma in childhood",
    "allergies": "Dust",
    "cardiology_consultations": "2025 consult - normal",
    "normal_ecg_min": 55,
    "normal_ecg_max": 100,
    "normal_pulse_min": 60,
    "normal_pulse_max": 95,
    "normal_temperature_min": 36.5,
    "normal_temperature_max": 37.4,
    "normal_humidity_min": 30,
    "normal_humidity_max": 60
  }
}
```

### PUT /api/patients/1

```json
{
  "email": "patient1.updated@bewell.com",
  "first_name": "Maria",
  "last_name": "Ionescu",
  "phone": "0723999999",
  "cnp": "1234567890123",
  "date_of_birth": "1995-05-10",
  "age": 29,
  "gender": "FEMALE",
  "profession": "Engineer",
  "workplace": "Updated Company"
}
```

---

## AWS Notes

At the moment, the database may run either:

* locally
* or on AWS RDS

To use AWS RDS, update only the backend `.env` file:

```env
DB_HOST=your-rds-endpoint
DB_PORT=3306
DB_NAME=be_well
DB_USER=admin
DB_PASSWORD=your-password
```

No frontend changes are needed if the backend still runs locally.

---

## Git Workflow

Do **not** push directly to `main`.

### Create a branch

```bash
git checkout -b feature/your-feature-name
```

### Commit

```bash
git add .
git commit -m "feat: short description"
```

### Push

```bash
git push origin feature/your-feature-name
```

Then open a Pull Request.

---

## Important Rules for the Team

* Never commit `.env`
* Never commit AWS `.pem` keys
* Always pull latest changes before starting work
* Install dependencies inside both `apps/api` and `apps/web`
* Test locally before pushing
* Do not rewrite shared SQL files without discussing with the team

---

## Roadmap

* [x] Database schema
* [x] Seed data
* [x] Patient CRUD API
* [ ] Patient frontend UI
* [ ] Authentication
* [ ] Cloud deployment
* [ ] Mobile integration
* [ ] Sensor ingestion
* [ ] Alerts and recommendations

---

## Quick Start Summary

```bash
# 1. clone
git clone <repo-url>
cd BeWell

# 2. setup backend
cd apps/api
npm install

# 3. setup frontend
cd ../web
npm install

# 4. setup database
# run database/init.sql in MySQL Workbench

# 5. run backend
cd ../api
npm run dev

# 6. run frontend
cd ../web
npm run dev
```
