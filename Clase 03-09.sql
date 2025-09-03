/* 
Triggers: 
    script para que antes o despues de que se realize una accion(insert, delete, update), haga un procedimiento
    3 etapas:
        after: Despues

        before: Antes
        insted of: Antes --> Before en oracle


*/
--Clase 03-09 
alter session set "_oracle_script"=true;

create TABLE empleado(
    id_empleado number PRIMARY key,
    nombre varchar2(50) not null,
    sueldo number(10),
    fecha_ingreso Date
);


create table auditoria_empleado(
    id_auditoria number primary key,
    id_empleado number not null,
    accion varchar2(30) not null,
    usuario varchar2(30) not null,
    fecha_auditoria Date not null
);
CREATE table auditoria_sueldo(
    id_auditoria number primary key,
    id_empleado number(3) not null,
    fecha Date not null,
    sueldo_anterior number(10) not null,
    sueldo_NUEVO number(10) not null,
    diferencia number(10) not null,
    tipo_cambio VARCHAR2(20) not null
);
create SEQUENCE sq_auditoria_empleado start with 1 INCREMENT by 1;
create SEQUENCE sq_sueldo start with 1 INCREMENT by 1;



create or replace TRIGGER tr_auditoria_empleado
AFTER insert on empleado 
for EACH row 
BEGIN
    insert into AUDITORIA_EMPLEADO values (SQ_AUDITORIA_EMPLEADO.nextval,:new.id_empleado,'Inserción de Datos',user, sysdate );
end;
/

insert into EMPLEADO values(1,'Jaime',500000,sysdate);

insert into EMPLEADO values(2,'Claudia',520000,sysdate);

SELECT * from empleado;

-- crear triger para gestionar y auditar cambios de sueldo

create or replace TRIGGER tr_auditoria_sueldo 
AFTER update on EMPLEADO
FOR EACH ROW
DECLARE
    v_diferencia number(10);
    v_tipo_cambio varchar2(20);
BEGIN
    v_diferencia:= :new.sueldo - :old.sueldo;
    if v_diferencia > 0 then 
        v_tipo_cambio:='Ahumento...';
    elsif v_diferencia < 0 then 
        v_tipo_cambio:='Disminución...';
    else
        v_tipo_cambio:='Sin Cambios...';
    end if;

    INSERT into AUDITORIA_SUELDO values(SQ_SUELDO.nextval,:new.id_empleado,sysdate,:old.sueldo,:new.sueldo,v_diferencia,v_tipo_cambio);
end;
/
--Actualizar el sueldo: 

update empleado set sueldo=450001 where ID_EMPLEADO=1;
SELECT * from EMPLEADO;
SELECT * from AUDITORIA_SUELDO;
--Crear trigger para validar que el sueldo sea positiva
create or REPLACE TRIGGER tr_validar_sueldo
before insert or update of sueldo on empleado
for EACH ROW
BEGIN
    if :new.sueldo < 0 then 
    DBMS_OUTPUT.PUT_LINE('Sueldo Negativo!!!!');
        :new.sueldo:=173000;
    end if;
end;
/

SELECT * from EMPLEADO;

update empleado set sueldo=-50 where ID_EMPLEADO=1;
--Package 
create or REPLACE PACKAGE pkg_ejemplo as 
    --Funcion 1
    FUNCTION fnc_suma(p_num1 number ,p_num2 number)
        return number;
    --Funcion 2
    FUNCTION fn_saludo(p_nombre varchar2)
        return VARCHAR2;
END pkg_ejemplo;
/
create or replace PACKAGE BODY pkg_ejemplo AS
    --Funcion 1
    FUNCTION fnc_suma(p_num1 number,p_num2 number)
        RETURN number 
        is 
        v_total number;
    BEGIN
        v_total:=p_num1 + p_num2;
        return v_total;
    end;
    --Funcion 2
    FUNCTION fn_saludo(p_nombre VARCHAR2)
        return VARCHAR2
        is
        BEGIN
            return ('Hola '||p_nombre);
        end;
END pkg_ejemplo;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE(PKG_EJEMPLO.FN_SALUDO('PEPE'));
    DBMS_OUTPUT.PUT_LINE(PKG_EJEMPLO.FNC_SUMA(2,2));
END;

