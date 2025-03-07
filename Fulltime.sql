drop table Fulltime;
CREATE TABLE Fulltime (
      empno VARCHAR(20) NOT NULL,
      name VARCHAR(20) NOT NULL,
      result INT NOT NULL,
      basicsalary INT NOT NULL,
      primary key (empno)
);

-- --------------------------------------------------------------------------

-- fulltime insert
drop procedure IF EXISTS FULLTIME_INSERT;
delimiter $$
create procedure FULLTIME_INSERT (
    in empno varchar(20), in name varchar(20),
    in result INT, in basicsalary INT,
    out RTN_CODE INT
)

begin
    set @count = -1;
    set @empno = empno;

    -- 중복사용자 예외 처리
    set @sql_select = 'SELECT COUNT(empno) into @count FROM Fulltime WHERE empno = ?;';
    prepare stmt1 from @sql_select;
    execute stmt1 using @empno;
    deallocate prepare stmt1;

    IF @count > 0 then
        SET RTN_CODE = 100; -- 이미 존재하는 사용자 있다.
    ELSE
        set @name = name;

        IF result < 0 then
            set @result = 0;
        ELSEIF result > 100000000 then
            set @result = 100000000;
        ELSE
            set @result = result;
        end if;

        IF basicsalary < 0 then
            set @basicsalary = 0;
        ELSEIF basicsalary > 100000000 then
            set @basicsalary = 100000000;
        ELSE
            set @basicsalary = basicsalary;
        end if;

        set @sql_insert = concat('insert into Fulltime (empno, name, result, basicsalary) ',
                                 'values(?, ?, ?, ?);');

        prepare stmt2 from @sql_insert;
        execute stmt2 using @empno, @name, @result, @basicsalary;
        deallocate prepare stmt2;
        COMMIT;
        SET RTN_CODE = 200;
    END IF;
end $$
delimiter ;

-- fulltime insert test
set @RTN_CODE = 1;
call FULLTIME_INSERT(
        '0001',
        '홍길동',
        100,
        100000000,
        @RTN_CODE
     );
select @RTN_CODE;
select * from fulltime;

-- --------------------------------------------------------------------------

-- fulltime delete
drop procedure IF EXISTS FULLTIME_DELETE;
delimiter $$
create procedure FULLTIME_DELETE (
    in empno varchar(20),
    out RTN_CODE INT
)

begin
    set @count = -1;
    set @empno = empno;

    -- 사용자 존재하는지 확인
    set @sql_select = 'SELECT COUNT(empno) into @count FROM Fulltime WHERE empno = ?;';
    prepare stmt1 from @sql_select;
    execute stmt1 using @empno;
    deallocate prepare stmt1;

    IF @count > 0 then
        set @sql_delete = 'delete from Fulltime where empno = ?';

        prepare stmt2 from @sql_delete;
        execute stmt2 using @empno;
        deallocate prepare stmt2;
        COMMIT;

        SET RTN_CODE = 200;
    ELSE
        SET RTN_CODE = 100; -- 사용자가 존재하지 않는다.
    END IF;
end $$
delimiter ;

-- fulltime delete test
set @RTN_CODE = 1;
call FULLTIME_DELETE(
        '0001',
        @RTN_CODE
     );
select @RTN_CODE;
select * from fulltime;

-- --------------------------------------------------------------------------

-- fulltime update
drop procedure IF EXISTS FULLTIME_UPDATE;
delimiter $$
create procedure FULLTIME_UPDATE (
    in empno varchar(20), in name varchar(20),
    in result INT, in basicsalary INT,
    out RTN_CODE INT
)

begin
    set @count = -1;
    set @empno = empno;

    -- 사용자 존재하는지 확인
    set @sql_select = 'SELECT COUNT(empno) into @count FROM Fulltime WHERE empno = ?;';
    prepare stmt1 from @sql_select;
    execute stmt1 using @empno;
    deallocate prepare stmt1;

    IF @count > 0 then
        set @name = name;

        IF result < 0 then
            set @result = 0;
        ELSEIF result > 100000000 then
            set @result = 100000000;
        ELSE
            set @result = result;
        end if;

        IF basicsalary < 0 then
            set @basicsalary = 0;
        ELSEIF basicsalary > 100000000 then
            set @basicsalary = 100000000;
        ELSE
            set @basicsalary = basicsalary;
        end if;

        set @sql_update = concat('update Fulltime ',
                                 'set name = ?, ',
                                 'result = ?, ',
                                 'basicsalary = ? ',
                                 'where empno = ?;');

        prepare stmt2 from @sql_update;
        execute stmt2 using @name, @result, @basicsalary, @empno;
        deallocate prepare stmt2;
        COMMIT;
        SET RTN_CODE = 200;
    ELSE
        SET RTN_CODE = 100; -- 사용자가 존재하지 않는다.
    END IF;
end $$
delimiter ;

-- fulltime update test
set @RTN_CODE = 1;
call FULLTIME_UPDATE(
        '0001',
        '박건희',
        100,
        100,
        @RTN_CODE
     );
select @RTN_CODE;
select * from fulltime;

-- --------------------------------------------------------------------------

-- fulltime salary raise
DROP PROCEDURE IF EXISTS FULLTIME_SALARY_RAISE;
DELIMITER $$
CREATE PROCEDURE FULLTIME_SALARY_RAISE(
    OUT RTN_CODE INT
)

BEGIN
    set @count = -1; -- 전체 직원수

    -- 전체 직원 수 조회
    set @sql_select = 'SELECT COUNT(empno) into @count FROM Fulltime;';
    prepare stmt1 from @sql_select;
    execute stmt1;
    deallocate prepare stmt1;

    IF @count > 0 then
        -- 상위 10%, 30%, 50%에 해당하는 인원수 계산 (커트라인)
        SET @top_10 = CEIL(@count * 0.1);
        SET @top_30 = CEIL(@count * 0.3);
        SET @top_50 = CEIL(@count * 0.5);

        -- 상위 10% 직원 급여 20% 인상
        set @sql_top_10 = ' UPDATE Fulltime
                            SET basicsalary = ROUND(basicsalary * 1.2)
                            WHERE empno IN (
                                SELECT empno
                                FROM (
                                    SELECT empno, RANK() OVER (ORDER BY result DESC) AS ranking
                                    FROM Fulltime
                                ) AS ranked
                                WHERE ranking <= @top_10
                            );';

        -- 상위 10~30% 직원 급여 10% 인상
        set @sql_top_30 = ' UPDATE Fulltime
                            SET basicsalary = ROUND(basicsalary * 1.1)
                            WHERE empno IN (
                                SELECT empno
                                FROM (
                                    SELECT empno, RANK() OVER (ORDER BY result DESC) AS ranking
                                    FROM Fulltime
                                ) AS ranked
                                WHERE ranking > @top_10 AND ranking <= @top_30
                            );';

        -- 상위 30~50% 직원 급여 5% 인상
        set @sql_top_50 = ' UPDATE Fulltime
                            SET basicsalary = ROUND(basicsalary * 1.05)
                            WHERE empno IN (
                                SELECT empno
                                FROM (
                                    SELECT empno, RANK() OVER (ORDER BY result DESC) AS ranking
                                    FROM Fulltime
                                ) AS ranked
                                WHERE ranking > @top_30 AND ranking <= @top_50
                            );';


        prepare stmt2 from @sql_top_10;
        execute stmt2;
        deallocate prepare stmt2;

        prepare stmt3 from @sql_top_30;
        execute stmt3;
        deallocate prepare stmt3;

        prepare stmt4 from @sql_top_50;
        execute stmt4;
        deallocate prepare stmt4;
        COMMIT;

        -- empno, basicsalary 에 대한 select 제공
        set @sql_select2 = 'SELECT empno, basicsalary FROM Fulltime
                            ORDER BY empno;';
        prepare stmt5 from @sql_select2;
        execute stmt5;
        deallocate prepare stmt5;

        SET RTN_CODE = 200;
    ELSE
        SET RTN_CODE = 100;
    END IF;
END $$
DELIMITER ;

-- fulltime salary raise test
set @RTN_CODE = 1;

call FULLTIME_INSERT( '0001', '홍길동', 0, 100, @RTN_CODE);
call FULLTIME_INSERT( '0002', '홍길동', 100, 100, @RTN_CODE);
call FULLTIME_INSERT( '0003', '홍길동', 200, 100, @RTN_CODE);
call FULLTIME_INSERT( '0004', '홍길동', 300, 100, @RTN_CODE);
call FULLTIME_INSERT( '0005', '홍길동', 400, 100, @RTN_CODE);
call FULLTIME_INSERT( '0006', '홍길동', 500, 100, @RTN_CODE);
call FULLTIME_INSERT( '0007', '홍길동', 600, 100, @RTN_CODE);
call FULLTIME_INSERT( '0008', '홍길동', 700, 100, @RTN_CODE);
call FULLTIME_INSERT( '0800', '홍길동', 700, 100, @RTN_CODE);
call FULLTIME_INSERT( '0009', '홍길동', 800, 100, @RTN_CODE);
call FULLTIME_INSERT( '0010', '홍길동', 900, 100, @RTN_CODE);
call FULLTIME_INSERT( '0011', '홍길동', 1000, 100, @RTN_CODE);

call FULLTIME_SALARY_RAISE(
        @RTN_CODE
     );
select @RTN_CODE;
select * from fulltime;
