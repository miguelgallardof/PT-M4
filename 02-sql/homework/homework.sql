-- Descargan el archivo de la base de datos, les conviene dejarlo en el escritorio así lo tienen a mano. El archivo se llama imdb-large.sqlite3.db
-- Abro simbolo del sistema, el path se abre en el directorio raiz
-- Pongo el comando dir (es como "l" en bash) para ver mi directorio
-- cd OneDrive, cd Escritorio (en mi caso, ustedes se desplazan el directorio hasta el lugar donde tienen guardado el archivo descargado)
-- Ignoro toda la primer parte del readme. Directamente pongo: sqlite3 imdb-large.sqlite3.db
-- .tables --> me muestra que ya tengo cargada la db
-- .schema actors --> es un ejemplo para mostrarles que ya me muestra la estrcutura de la tabla
-- Si todo está ok, ya podemos empezar
-- Puedo usar los comandos del readme .header on y .mode column para que me formatee la data como tablas
-- También está el comando .mode box --> es más lindo! Lo deja en forma de tablita con rayas

-- Recuperar todas las películas que se hicieron en el año 1902 y que obtuvieron un puntaje mayor a 5 en IMBD
SELECT name, year FROM movies
WHERE year = 1902 AND rank > 5
LIMIT 10;

-- 1 Buscá todas las películas filmadas en el año que naciste.
SELECT * FROM movies
WHERE year = 1989
LIMIT 10;

-- 2 Cuantas películas hay en la DB que sean del año 1982?
SELECT COUNT(*) AS total FROM movies
WHERE year = 1982
LIMIT 10;

-- 3 Buscá actores que tengan el substring stack en su apellido.
SELECT * FROM actors
WHERE LOWER(last_name) LIKE '%stack%';
-- WHERE last_name ILIKE '%stack%';

-- 4 Buscá los 10 nombres y apellidos más populares entre los actores. Cuantos actores tienen cada uno de esos nombres y apellidos?
SELECT first_name, last_name, COUNT(*) as total
FROM actors
GROUP BY LOWER(first_name), LOWER(last_name)
ORDER BY total DESC
LIMIT 10;

-- 5 Listá el top 100 de actores más activos junto con el número de roles que haya realizado.
SELECT actors.first_name, actors.last_name, COUNT(*) as total
FROM actors
JOIN roles ON actors.id = roles.actor_id
GROUP BY actors.id
ORDER BY total DESC
LIMIT 10;

-- 6 Cuantas películas tiene IMDB por género? Ordená la lista por el género menos popular.
SELECT movies_genres.genre, COUNT(*) as total
FROM movies_genres
JOIN movies ON movies.id = movies_genres.movie_id
GROUP BY movies_genres.genre
ORDER BY total
LIMIT 10;

-- 7 Listá el nombre y apellido de todos los actores que trabajaron en la película "Braveheart" de 1995, ordená la lista alfabéticamente por apellido.
SELECT actors.first_name, actors.last_name
FROM actors
JOIN roles ON actors.id = roles.actor_id
JOIN movies ON movies.id = roles.movie_id
WHERE movies.name = 'Braveheart' AND movies.year = 1995
ORDER BY actors.last_name;
LIMIT 10;

-- 8 Listá todos los directores que dirigieron una película de género 'Film-Noir' en un año bisiesto (para reducir la complejidad, asumí que cualquier año divisible por cuatro es bisiesto). Tu consulta debería devolver el nombre del director, el nombre de la peli y el año. Todo ordenado por el nombre de la película.
SELECT directors.first_name, movies.name, movies.year
FROM directors
JOIN movies_directors ON directors.id = movies_directors.director_id
JOIN movies ON movies.id = movies_directors.movie_id
JOIN movies_genres ON movies.id = movies_genres.movie_id
WHERE movies_genres.genre = 'Film-Noir' AND movies.year % 4 = 0
ORDER BY movies.name;


-- 9 Listá todos los actores que hayan trabajado con Kevin Bacon en películas de Drama (incluí el título de la peli). Excluí al señor Bacon de los resultados.
SELECT (actors.first_name || " " || actors.last_name) as name, movies.name
FROM actors 
JOIN roles ON actors.id = roles.actor_id
JOIN movies ON movies.id = roles.movie_id
JOIN movies_genres ON movies.id = movies_genres.movie_id
WHERE movies.id IN (
    SELECT roles.movie_id
    FROM roles
    JOIN actors ON actors.id = roles.actor_id
    WHERE actors.first_name = 'Kevin' AND actors.last_name = 'Bacon'
) AND movies_genres.genre = 'Drama' AND (actors.first_name || " " || actors.last_name) != 'Kevin Bacon'
ORDER BY name;

-- 10 Qué actores actuaron en una película antes de 1900 y también en una película después del 2000?
SELECT actors.first_name, actors.last_name
FROM actors
WHERE actors.id IN (
    SELECT roles.actor_id
    FROM roles
    JOIN movies ON movies.id = roles.movie_id
    WHERE movies.year < 1990
) AND actors.id IN (
    SELECT roles.actor_id
    FROM roles
    JOIN movies ON movies.id = roles.movie_id
    WHERE movies.year > 2000
)
ORDER BY actors.last_name;

-- 11 Buscá actores que actuaron en cinco o más roles en la misma película después del año 1990. Noten que los ROLES pueden tener duplicados ocasionales, sobre los cuales no estamos interesados: queremos actores que hayan tenido cinco o más roles DISTINTOS (DISTINCT cough cough) en la misma película. Escribí un query que retorne los nombres del actor, el título de la película y el número de roles (siempre debería ser > 5).
SELECT artors.first_name, actors.last_name, movies.name, COUNT(DISTINCT roles.role)  as total 
FROM actors
JOIN roles ON actors.id = roles.actor_id
JOIN movies ON movies.id = roles.movie_id
WHERE movies.year > 1990
GROUP BY actors.id, movies.id,
HAVING total > 5
ORDER BY actors.first_name;


-- 12 Para cada año, contá el número de películas en ese años que sólo tuvieron actrices femeninas.
SELECT movies.year, COUNT(*) as total
FROM movies
WHERE movies.id NOT IN (
    SELECT roles.movie_id
    FROM roles
    JOIN actors ON actors.id = roles.actor_id
    WHERE actors.gender = 'M'
)
GROUP BY movies.year
ORDER BY movies.year DESC;