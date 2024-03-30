/*
Задание 5. 
Определите ранг каждого тренера в зависимости от результата его пловца, поместите имя и фамилию тренера в отдельное поле.
*/
SELECT	DeclaredTime,
		Distanse,
		Style,
		r.SwimmerID,
		r.CompetitionId,
		c.CoachID,
		c.FirstName,
		c.LastName,
		--определяем ранг тренера в зависимости от дистанции и стиля, в которых соревнуются их пловцы (в каждых дистанции и стиле рейтинг будет свой)
		DENSE_RANK() OVER (PARTITION BY Distanse, Style ORDER BY DeclaredTime) AS CoachRank,
		CONCAT(c.FirstName, ' ', c.LastName) AS Coach
FROM [dbo].[Result] r  
JOIN [dbo].[Swimmer] s ON r.[SwimmerId] = s.SwimmerId
JOIN [dbo].[Coach] c ON s.[CoachId] = c.CoachId
ORDER BY CoachRank

/*
Задание 6. 
Создайте объект для нахождения всех пловцов-победителей (1, 2 и 3 место) по двум параметрам – имя соревнования или год соревнования.  
*/
--создаем процедуру с двумя входными парамерами - CompetitionName и YearComp
CREATE PROCEDURE WinnersByYearComp
    @CompetitionName NVARCHAR(100) = NULL,
    @YearComp INT = NULL
AS
BEGIN
    SELECT * FROM 
					(SELECT s.FirstName,
							s.LastName,
							c.CompetitionName,
							YEAR(c.StartDate) AS YearComp,
							-- определяем места пловцов по времени (от меньшего к большему) и разбиваем их по названиям соревнований и годам
							DENSE_RANK() OVER (PARTITION BY c.CompetitionId ORDER BY r.DeclaredTime) AS WinnerComp,
							DENSE_RANK() OVER (PARTITION BY YEAR(c.StartDate) ORDER BY r.DeclaredTime) AS WinnerYear
					FROM [dbo].[Result] r
					JOIN [dbo].[Swimmer] s ON r.[SwimmerId] = s.SwimmerId
					JOIN [dbo].[Competition] c ON r.[CompetitionId] = c.CompetitionId
					WHERE  
						(@CompetitionName IS NULL OR c.[CompetitionName] = @CompetitionName)
						AND (@YearComp IS NULL OR YEAR(c.[StartDate]) = @YearComp)) s
	--выбираем только пловцов-победителей
	WHERE WinnerComp IN (1,2,3) OR WinnerYear IN (1,2,3) 
END;

--вызываем процедуру с передачей определенных значений
EXEC WinnersByYearComp @CompetitionName = 'Summer Olympic Games';
EXEC WinnersByYearComp @YearComp = 1980;


/*
Задание 7. 
Создайте объект для нахождения общего рейтинга топ 10 тренеров за всю историю соревнований, 
где рейтинг определяется общим количеством баллов за победы пловцов (1 место – 3 балла, 2 место – 2 балла, 3 место – 1 балл).
*/

CREATE PROCEDURE TopCoachesByPoints
AS
BEGIN
    SELECT TOP 10 -- если нужно учесть тренеров с одинаковым количеством баллов, можно использовать WITH TIES
    CoachName,
	--присваиваем баллы тренерам в зависимости от мест их пловцов
    SUM(CASE WHEN CoachRank = 1 THEN 3
             WHEN CoachRank = 2 THEN 2
             WHEN CoachRank = 3 THEN 1
             ELSE 0 END) AS Points
    FROM
	-- подзапрос для получения данных о местах тренеров в зависимости от результатов их пловцов
    (SELECT c.[CoachID],
            c.[FirstName],
            c.[LastName],
            DENSE_RANK() OVER (PARTITION BY r.[Distanse], r.[Style] ORDER BY r.[DeclaredTime]) AS CoachRank,
            CONCAT(c.FirstName, ' ', c.LastName) AS CoachName
        FROM [dbo].[Result] r  
        JOIN [dbo].[Swimmer] s ON r.SwimmerId = s.SwimmerId
        JOIN [dbo].[Coach] c ON s.CoachId = c.CoachId
    ) s
    GROUP BY CoachName
    ORDER BY Points DESC;
END;
--выполняем процедуру
EXEC TopCoachesByPoints;

