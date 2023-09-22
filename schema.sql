/* Database schema to keep the structure of entire database. */

CREATE TABLE animals (
    id INT GENERATED ALWAYS AS IDENTITY, 
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    escape_attempts INT,
    neutered BOOLEAN NOT NULL,
    weight_kg DECIMAL NOT NULL,
    PRIMARY KEY(id)
);

ALTER TABLE animals ADD COLUMN species VARCHAR(50);
ALTER TABLE animals DROP COLUMN species;
ALTER TABLE animals ADD COLUMN species_id INT, ADD COLUMN owner_id INT;
ALTER TABLE animals ADD CONSTRAINT fk_species FOREIGN KEY(species_id) REFERENCES species(id);
ALTER TABLE animals ADD CONSTRAINT fk_owners FOREIGN KEY(owner_id) REFERENCES owners(id);

CREATE TABLE owners (
    id INT GENERATED ALWAYS AS IDENTITY,
    full_name VARCHAR(100),
    age INT,
    PRIMARY KEY(id)
);

CREATE TABLE species(
    id INT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100),
    PRIMARY KEY(id)
);

CREATE TABLE vets(
    id INT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100),
    age INT,
    date_of_graduation DATE,
    PRIMARY KEY(id)
);

CREATE TABLE specializations(
    vets_id INT,
    species_id INT,
    CONSTRAINT fk_vets FOREIGN KEY(vets_id) REFERENCES vets(id),
    CONSTRAINT fk_species FOREIGN KEY(species_id) REFERENCES species(id)
);

CREATE TABLE visits(
    animals_id INT,
    vets_id INT,
    visit_date DATE,
    CONSTRAINT fk_animals FOREIGN KEY(animals_id) REFERENCES animals(id),
    CONSTRAINT fk_vets FOREIGN KEY(vets_id) REFERENCES vets(id)
);