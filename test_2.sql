/*
������� 5. 
���������� ���� ������� ������� � ����������� �� ���������� ��� ������, ��������� ��� � ������� ������� � ��������� ����.
*/
SELECT	DeclaredTime,
		Distanse,
		Style,
		r.SwimmerID,
		r.CompetitionId,
		c.CoachID,
		c.FirstName,
		c.LastName,
		--���������� ���� ������� � ����������� �� ��������� � �����, � ������� ����������� �� ������ (� ������ ��������� � ����� ������� ����� ����)
		DENSE_RANK() OVER (PARTITION BY Distanse, Style ORDER BY DeclaredTime) AS CoachRank,
		CONCAT(c.FirstName, ' ', c.LastName) AS Coach
FROM [dbo].[Result] r  
JOIN [dbo].[Swimmer] s ON r.[SwimmerId] = s.SwimmerId
JOIN [dbo].[Coach] c ON s.[CoachId] = c.CoachId
ORDER BY CoachRank

/*
������� 6. 
�������� ������ ��� ���������� ���� �������-����������� (1, 2 � 3 �����) �� ���� ���������� � ��� ������������ ��� ��� ������������.  
*/
--������� ��������� � ����� �������� ���������� - CompetitionName � YearComp
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
							-- ���������� ����� ������� �� ������� (�� �������� � ��������) � ��������� �� �� ��������� ������������ � �����
							DENSE_RANK() OVER (PARTITION BY c.CompetitionId ORDER BY r.DeclaredTime) AS WinnerComp,
							DENSE_RANK() OVER (PARTITION BY YEAR(c.StartDate) ORDER BY r.DeclaredTime) AS WinnerYear
					FROM [dbo].[Result] r
					JOIN [dbo].[Swimmer] s ON r.[SwimmerId] = s.SwimmerId
					JOIN [dbo].[Competition] c ON r.[CompetitionId] = c.CompetitionId
					WHERE  
						(@CompetitionName IS NULL OR c.[CompetitionName] = @CompetitionName)
						AND (@YearComp IS NULL OR YEAR(c.[StartDate]) = @YearComp)) s
	--�������� ������ �������-�����������
	WHERE WinnerComp IN (1,2,3) OR WinnerYear IN (1,2,3) 
END;

--�������� ��������� � ��������� ������������ ��������
EXEC WinnersByYearComp @CompetitionName = 'Summer Olympic Games';
EXEC WinnersByYearComp @YearComp = 1980;


/*
������� 7. 
�������� ������ ��� ���������� ������ �������� ��� 10 �������� �� ��� ������� ������������, 
��� ������� ������������ ����� ����������� ������ �� ������ ������� (1 ����� � 3 �����, 2 ����� � 2 �����, 3 ����� � 1 ����).
*/

CREATE PROCEDURE TopCoachesByPoints
AS
BEGIN
    SELECT TOP 10 -- ���� ����� ������ �������� � ���������� ����������� ������, ����� ������������ WITH TIES
    CoachName,
	--����������� ����� �������� � ����������� �� ���� �� �������
    SUM(CASE WHEN CoachRank = 1 THEN 3
             WHEN CoachRank = 2 THEN 2
             WHEN CoachRank = 3 THEN 1
             ELSE 0 END) AS Points
    FROM
	-- ��������� ��� ��������� ������ � ������ �������� � ����������� �� ����������� �� �������
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
--��������� ���������
EXEC TopCoachesByPoints;

