drop table Parttime;
CREATE TABLE Parttime (
      empno VARCHAR(20) NOT NULL,
      name VARCHAR(20) NOT NULL,
      hourwage INT NOT NULL,
      workhour INT NOT NULL,
      primary key (empno)
);

-- --------------------------------------------------------------------------

-- parttime insert
drop procedure IF EXISTS PARTTIME_INSERT;
delimiter $$
create procedure PARTTIME_INSERT (
    in empno varchar(20), in name varchar(20),
    in hourwage INT, in workhour INT,
    out RTN_CODE INT
)

begin
    set @count = -1;
    set @empno = empno;

    -- 중복사용자 예외 처리
    set @sql_select = 'SELECT COUNT(empno) into @count FROM Parttime WHERE empno = ?;';
    prepare stmt1 from @sql_select;
    execute stmt1 using @empno;
    deallocate prepare stmt1;

    IF @count > 0 then
        SET RTN_CODE = 100; -- 이미 존재하는 사용자 있다.
    ELSE
        set @name = name;

        IF hourwage < 10030 then
            set @hourwage = 10030;
        ELSEIF hourwage > 100000000 then
            set @hourwage = 100000000;
        ELSE
            set @hourwage = hourwage;
        end if;

        IF workhour < 0 then
            set @workhour = 0;
        ELSEIF workhour > 100000000 then
            set @workhour = 100000000;
        ELSE
            set @workhour = workhour;
        end if;

        set @sql_insert = concat('insert into Parttime (empno, name, hourwage, workhour) ',
                                 'values(?, ?, ?, ?);');

        prepare stmt2 from @sql_insert;
        execute stmt2 using @empno, @name, @hourwage, @workhour;
        deallocate prepare stmt2;
        COMMIT;
        SET RTN_CODE = 200;
    END IF;
end $$
delimiter ;

-- fulltime insert test
set @RTN_CODE = 1;
call PARTTIME_INSERT(
        '0001',
        '홍길동',
        100,
        24,
        @RTN_CODE
     );
select @RTN_CODE;
select * from parttime;

-- --------------------------------------------------------------------------

-- fulltime delete
drop procedure IF EXISTS PARTTIME_DELETE;
delimiter $$
create procedure PARTTIME_DELETE (
    in empno varchar(20),
    out RTN_CODE INT
)

begin
    set @count = -1;
    set @empno = empno;

    -- 사용자 존재하는지 확인
    set @sql_select = 'SELECT COUNT(empno) into @count FROM Parttime WHERE empno = ?;';
    prepare stmt1 from @sql_select;
    execute stmt1 using @empno;
    deallocate prepare stmt1;

    IF @count > 0 then
        set @sql_delete = 'delete from Parttime where empno = ?';

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
call PARTTIME_DELETE(
        '0001',
        @RTN_CODE
     );
select @RTN_CODE;
select * from parttime;

-- --------------------------------------------------------------------------

-- fulltime update
drop procedure IF EXISTS PARTTIME_UPDATE;
delimiter $$
create procedure PARTTIME_UPDATE (
    in empno varchar(20), in name varchar(20),
    in hourwage INT, in workhour INT,
    out RTN_CODE INT
)

begin
    set @count = -1;
    set @empno = empno;

    -- 사용자 존재하는지 확인
    set @sql_select = 'SELECT COUNT(empno) into @count FROM Parttime WHERE empno = ?;';
    prepare stmt1 from @sql_select;
    execute stmt1 using @empno;
    deallocate prepare stmt1;

    IF @count > 0 then
        set @name = name;

        IF hourwage < 10030 then
            set @hourwage = 10030;
        ELSEIF hourwage > 100000000 then
            set @hourwage = 100000000;
        ELSE
            set @hourwage = hourwage;
        end if;

        IF workhour < 0 then
            set @workhour = 0;
        ELSEIF workhour > 100000000 then
            set @workhour = 100000000;
        ELSE
            set @workhour = workhour;
        end if;

        set @sql_update = concat('update Parttime ',
                                 'set name = ?, ',
                                 'hourwage = ?, ',
                                 'workhour = ? ',
                                 'where empno = ?;');

        prepare stmt2 from @sql_update;
        execute stmt2 using @name, @hourwage, @workhour, @empno;
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
call PARTTIME_UPDATE(
        '0001',
        '박건희',
        100,
        100,
        @RTN_CODE
     );
select @RTN_CODE;
select * from parttime;
