/*Queries that provide answers to the questions from all projects.*/

SELECT * from animals WHERE name LIKE '%mon';
SELECT name FROM animals WHERE date_of_birth BETWEEN '2016-01-01' AND '2019-12-31';
SELECT name FROM animals WHERE neutered = true AND escape_attempts < 3;
SELECT date_of_birth FROM animals WHERE name IN ('Agumon', 'Pikachu');
SELECT name, escape_attempts FROM animals WHERE weight_kg > 10.5;
SELECT * FROM animals WHERE neutered = true;
SELECT * FROM animals WHERE name NOT IN ('Gabumon');
SELECT * FROM animals WHERE weight_kg BETWEEN 10.4 AND 17.3 OR (weight_kg = 10.4 OR weight_kg = 17.3);

BEGIN;
UPDATE animals SET species = 'unspecified';
SELECT species FROM animals;
ROLLBACK;
SELECT species FROM animals;

BEGIN;
UPDATE animals SET species = 'digimon' WHERE name LIKE '%mon';
UPDATE animals SET species = 'pokemon' WHERE species IS NULL;
COMMIT;

BEGIN;
DELETE FROM animals;
ROLLBACK;

BEGIN;
DELETE FROM animals WHERE date_of_birth > '2022-01-01';
SAVEPOINT DEL2022;
UPDATE animals SET weight_kg = weight_kg * (-1);
ROLLBACK TO DEL2022;
UPDATE animals SET weight_kg = weight_kg * (-1) WHERE weight_kg < 0;
COMMIT;

-- How many animals are there?
SELECT COUNT(*) FROM animals;

-- How many animals have never tried to escape?
SELECT COUNT(*) FROM animals WHERE escape_attempts = 0;

-- What is the average weight of animals?
SELECT AVG(weight_kg) as average FROM animals;

-- Who escapes the most, neutered or not neutered animals?
SELECT neutered, AVG(escape_attempts) FROM animals GROUP BY neutered;

-- What is the minimum and maximum weight of each type of animal?
SELECT species, MIN(weight_kg), MAX(weight_kg) FROM animals GROUP BY species;

-- What is the average number of escape attempts per animal type of those born between 1990 and 2000?
SELECT species, AVG(escape_attempts) FROM animals  WHERE date_of_birth BETWEEN '1990-01-01' AND '2000-12-31' GROUP BY species;

-- What animals belong to Melody Pond?
SELECT o.full_name, a.name FROM owners o INNER JOIN animals a ON a.owner_id = o.id WHERE o.id = 4;

-- List of all animals that are pokemon
SELECT a.name, s.name as animal_type FROM animals a INNER JOIN  species s ON s.id = a.species_id WHERE s.id = 1;

-- List all owners and their animals, including those that don't own any animal.
SELECT o.full_name, a.name FROM owners o LEFT JOIN animals a ON a.owner_id = o.id;

-- How many animals are there per species?
SELECT s.name, COUNT(*) FROM animals a JOIN species s ON a.species_id = s.id GROUP BY s.name;

-- List all Digimon owned by Jennifer Orwell.
SELECT a.name, s.name as animal_type, o.full_name FROM animals a 
    INNER JOIN species s ON s.id = a.species_id 
    INNER JOIN owners o ON o.id = a.owner_id WHERE s.id = 2 AND o.id = 2;

-- List all animals owned by Dean Winchester that haven't tried to escape.
SELECT a.name, o.full_name FROM animals a 
    INNER JOIN owners o ON o.id = a.owner_id WHERE a.escape_attempts = 0 AND o.id = 5;

-- Who owns the most animals?
SELECT full_name, COUNT(*) AS count FROM animals a
    JOIN owners o ON a.owner_id = o.id
    GROUP BY full_name
    HAVING COUNT(*) = (
        SELECT MAX(count) FROM (SELECT COUNT(*) AS count FROM animals GROUP BY owner_id) t)
    ORDER BY full_name;

-- Who was the last animal seen by William Tatcher?
SELECT v.visit_date, a.name as animal_name, vt.name as vet_name FROM visits v 
    INNER JOIN animals a ON a.id = v.animals_id
    INNER JOIN vets vt ON vt.id = v.vets_id
    WHERE v.vets_id = 1 AND v.visit_date = (SELECT MAX(visit_date) FROM visits WHERE animals_id = a.id);

-- How many different animals did Stephanie Mendez see?
SELECT COUNT(*) FROM visits v
    INNER JOIN animals a ON a.id = v.animals_id
    INNER JOIN vets vt ON vt.id = v.vets_id
    WHERE v.vets_id = 3;

-- List all vets and their specialties, including vets with no specialties.
SELECT vt.name as vet_name, s.name as species_name FROM vets vt
    LEFT JOIN specializations sp ON sp.vets_id = vt.id
    LEFT JOIN species s ON s.id = sp.species_id;

-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT a.name, vt.name as vet_name, v.visit_date FROM visits v
    INNER JOIN vets vt ON vt.id = v.vets_id
    INNER JOIN animals a ON a.id = v.animals_id
    WHERE v.vets_id = 3 AND v.visit_date BETWEEN '2020-04-01' AND '2020-08-30';

-- What animal has the most visits to vets?
SELECT a.name, COUNT(v.animals_id) count FROM visits v 
    JOIN animals a ON a.id = v.animals_id GROUP BY a.name
    HAVING COUNT(v.animals_id) = (
        SELECT MAX(count) FROM (SELECT COUNT(v.animals_id) count FROM visits v GROUP BY animals_id) t);

-- Who was Maisy Smith's first visit?
SELECT vt.name as vet_name, MIN(v.visit_date) as first_visit FROM visits v 
    INNER JOIN vets vt ON vt.id = v.vets_id 
    WHERE vt.id = 2 GROUP BY vt.name;

-- Details for most recent visit: animal information, vet information, and date of visit.
SELECT a.name, v.name, vi.visit_date FROM visits vi
    JOIN animals a ON a.id = vi.animals_id
    JOIN vets v ON v.id = vi.vets_id GROUP BY a.name, v.name, vi.visit_date
    HAVING vi.visit_date = (SELECT MAX(vi.visit_date) FROM visits vi);

-- How many visits were with a vet that did not specialize in that animal's species?
SELECT COUNT(*) AS count FROM visits vi
    INNER JOIN animals a ON vi.animals_id = a.id
    WHERE vi.vets_id NOT IN (SELECT sp.vets_id FROM specializations sp WHERE sp.species_id = a.species_id);

-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT a.species_id, COUNT(*) AS count, s.name FROM visits vi 
    INNER JOIN animals a ON vi.animals_id = a.id
    INNER JOIN specializations sp ON sp.species_id = a.species_id 
    INNER JOIN vets v ON v.id = vi.vets_id 
    INNER JOIN species s ON s.id = sp.species_id 
    WHERE v.id = 2
    GROUP BY a.species_id, s.name
    ORDER BY count DESC LIMIT 1;

-- Create index for the animal_id column
CREATE INDEX animals_index ON visits(animal_id);

-- Create index for the vet_id colunm in the visits table
CREATE INDEX vet_id_index ON visits (vet_id);

-- Create index for the email colunm in the owners table
CREATE INDEX owners_email_index ON owners(email);