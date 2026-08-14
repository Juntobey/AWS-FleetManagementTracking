CREATE TABLE IF NOT EXISTS public.vehicles (
    id SERIAL PRIMARY KEY,
    license_plate VARCHAR(20) NOT NULL,
    make_model VARCHAR(100) NOT NULL,
    current_mileage INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL
);