drop table Student;
CREATE TABLE Student (
    sno VARCHAR(20) NOT NULL,
    name VARCHAR(20) NOT NULL,
    korean INT NOT NULL,
    english INT NOT NULL,
    math INT NOT NULL,
    science INT NOT NULL,
    primary key (sno)
);

-- --------------------------------------------------------------------------

-- student insert
drop procedure IF EXISTS STUDENT_INSERT;
delimiter $$
create procedure STUDENT_INSERT (
    in sno varchar(20), in name varchar(20),
    in korean INT, in english INT, in math INT, in science INT,
    out RTN_CODE INT
)

begin
    set @count = -1;
    set @sno = sno;

    -- 중복사용자 예외 처리
    set @sql_select = 'SELECT COUNT(sno) into @count FROM Student WHERE sno = ?;';
    prepare stmt1 from @sql_select;
    execute stmt1 using @sno;
    deallocate prepare stmt1;

    IF @count > 0 then
        SET RTN_CODE = 100; -- 이미 존재하는 사용자 있다.
    ELSE
        IF korean < 0 then
            set @korean = 0;
        ELSEIF korean > 100 then
            set @korean = 100;
        ELSE
            set @korean = korean;
        end if;

        IF english < 0 then
            set @english = 0;
        ELSEIF english > 100 then
            set @english = 100;
        ELSE
            set @english = english;
        end if;

        IF math < 0 then
            set @math = 0;
        ELSEIF math > 100 then
            set @math = 100;
        ELSE
            set @math = math;
        end if;

        IF science < 0 then
            set @science = 0;
        ELSEIF science > 100 then
            set @science = 100;
        ELSE
            set @science = science;
        end if;

        set @sql_insert = concat('insert into Student (sno, name, korean, english, math, science) ',
                             'values(?, ?, ?, ?, ?, ?);');

        prepare stmt2 from @sql_insert;
        execute stmt2 using @sno, @name, @korean, @english, @math, @science;
        deallocate prepare stmt2;
        COMMIT;
        SET RTN_CODE = 200;
    END IF;
end $$
delimiter ;

-- student insert test
set @RTN_CODE = 1;
call STUDENT_INSERT(
        '2017103988',
        '홍길동',
        500,
        0,
        -1,
        100,
        @RTN_CODE
);
select @RTN_CODE;
select * from student;

-- --------------------------------------------------------------------------

-- student delete
drop procedure IF EXISTS STUDENT_DELETE;
delimiter $$
create procedure STUDENT_DELETE (
    in sno varchar(20),
    out RTN_CODE INT
)

begin
    set @count = -1;
    set @sno = sno;

    -- 사용자 존재하는지 확인
    set @sql_select = 'SELECT COUNT(sno) into @count FROM Student WHERE sno = ?;';
    prepare stmt1 from @sql_select;
    execute stmt1 using @sno;
    deallocate prepare stmt1;

    IF @count > 0 then
        set @sql_delete = 'delete from Student where sno = ?';

        prepare stmt2 from @sql_delete;
        execute stmt2 using @sno;
        deallocate prepare stmt2;
        COMMIT;

        SET RTN_CODE = 200;
    ELSE
        SET RTN_CODE = 100; -- 사용자가 존재하지 않는다.
    END IF;
end $$
delimiter ;

-- student delete test
set @RTN_CODE = 1;
call STUDENT_DELETE(
        '2017103984',
        @RTN_CODE
     );
select @RTN_CODE;
select * from student;

-- --------------------------------------------------------------------------

-- student update
drop procedure IF EXISTS STUDENT_UPDATE;
delimiter $$
create procedure STUDENT_UPDATE (
    in sno varchar(20), in name varchar(20),
    in korean INT, in english INT, in math INT, in science INT,
    out RTN_CODE INT
)

begin
    set @count = -1;
    set @sno = sno;

    -- 사용자 존재하는지 확인
    set @sql_select = 'SELECT COUNT(sno) into @count FROM Student WHERE sno = ?;';
    prepare stmt1 from @sql_select;
    execute stmt1 using @sno;
    deallocate prepare stmt1;

    IF @count > 0 then
        set @name = name;

        IF korean < 0 then
            set @korean = 0;
        ELSEIF korean > 100 then
            set @korean = 100;
        ELSE
            set @korean = korean;
        end if;

        IF english < 0 then
            set @english = 0;
        ELSEIF english > 100 then
            set @english = 100;
        ELSE
            set @english = english;
        end if;

        IF math < 0 then
            set @math = 0;
        ELSEIF math > 100 then
            set @math = 100;
        ELSE
            set @math = math;
        end if;

        IF science < 0 then
            set @science = 0;
        ELSEIF science > 100 then
            set @science = 100;
        ELSE
            set @science = science;
        end if;

        set @sql_update = concat('update student ',
                                 'set name = ?, ',
                                 'korean = ?, ',
                                 'english = ?, ',
                                 'math = ?, ',
                                 'science = ? ',
                                 'where sno = ?;');

        prepare stmt2 from @sql_update;
        execute stmt2 using @name, @korean, @english, @math, @science, @sno;
        deallocate prepare stmt2;
        COMMIT;
        SET RTN_CODE = 200;
    ELSE
        SET RTN_CODE = 100; -- 사용자가 존재하지 않는다.
    END IF;
end $$
delimiter ;

-- student update test
set @RTN_CODE = 1;
call STUDENT_UPDATE(
        '2017103985',
        '박건희',
        -5,
        100,
        100,
        100,
        @RTN_CODE
     );
select @RTN_CODE;
select * from student;
