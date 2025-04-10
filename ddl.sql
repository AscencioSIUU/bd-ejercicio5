CREATE DATABASE pet_shop;
CREATE TABLE "specie" (
  "id" serial PRIMARY KEY,
  "name" varchar(255)
);

CREATE TABLE "specie_races" (
  "id" serial PRIMARY KEY,
  "specie_id" int REFERENCES "specie" ("id"),
  "name" varchar(255)
);

CREATE TABLE "owner" (
  "id" serial PRIMARY KEY,
  "name" varchar(255),
  "phone" varchar(15),
  "address" text
);

CREATE TABLE "pet" (
  "id" serial PRIMARY KEY,
  "spcie_race_id" int REFERENCES "specie_races" ("id"),
  "owner_id" int REFERENCES "owner" ("id"),
  "weight" numeric(10,2),
  "birth_date" date,
  "isAlive" boolean
);

CREATE TABLE "vaccine" (
  "id" serial PRIMARY KEY,
  "name" varchar(255)
);

CREATE TABLE "pet_vaccines" (
  "id" serial PRIMARY KEY,
  "pet_id" int REFERENCES "pet" ("id"),
  "vaccine_id" int REFERENCES "vaccine" ("id")
);

CREATE TABLE "medical_treatment" (
  "id" serial PRIMARY KEY,
  "pet_id" int REFERENCES "pet" ("id"),
  "description" text
);

CREATE TABLE "category" (
  "id" serial PRIMARY KEY,
  "name" varchar(255)
);

CREATE TABLE "product" (
  "id" serial PRIMARY KEY,
  "category_id" int REFERENCES "category" ("id"),
  "name" varchar(255),
  "brand" varchar(255),
  "current_stock" int
);

CREATE TABLE "inventory_logs" (
  "id" serial PRIMARY KEY,
  "quantity" int,
  "product_id" int REFERENCES "product" ("id")
);

CREATE TABLE "appointment" (
  "id" serial PRIMARY KEY,
  "pet_id" int REFERENCES "pet" ("id"),
  "owner_id" int REFERENCES "owner" ("id"),
  "date" timestamp
);

CREATE TABLE "sale" (
  "id" serial PRIMARY KEY,
  "owner_id" int REFERENCES "owner" ("id"),
  "date" timestamp
);

CREATE TABLE "sale_details" (
  "id" serial PRIMARY KEY,
  "sale_id" int REFERENCES "sale" ("id"),
  "product_id" int REFERENCES "product" ("id"),
  "quantity" int
);

CREATE TABLE truncate_log (
    id serial PRIMARY KEY,
    table_name text,
    truncated_at timestamp DEFAULT now()
);

CREATE TABLE sale_delete_log (
    id serial PRIMARY KEY,
    sale_id int,
    owner_id int,
    deleted_at timestamp DEFAULT now()
);

CREATE TABLE IF NOT EXISTS product_stock_log (
    id serial PRIMARY KEY,
    product_id int,
    old_stock int,
    new_stock int,
    changed_at timestamp DEFAULT now()
);