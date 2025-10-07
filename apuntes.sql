
--Bloqus anonimos
DECLARE
    v_edad number;
    v_rut number;
    --record: sirve como dicconario de datos
    type empleado_rec is record (
        pnombre VARCHAR2(20),
        appaterno VARCHAR2(20),
        apmaterno VARCHAR2(20)
    );

BEGIN
    select trunc(months_between(fecha_nacimiento, sysdate)/12) into v_edad from dual where rut=v_rut; --tabla a eleccion
    dbms_output.put_line('La edad es: ' || v_edad);
end;

--Cursores: 
DECLARE 
    CURSOR c_socio IS
        SELECT 'Juan' pnombre, 'Perez' appaterno, 'Lopez' apmaterno FROM dual; -- Ejemplo
    
    TYPE empleado_rec IS RECORD (
        pnombre VARCHAR2(20),
        appaterno VARCHAR2(20),
        apmaterno VARCHAR2(20)
    );
    v_empleado empleado_rec;
BEGIN
    OPEN c_socio;
    LOOP
        FETCH c_socio INTO v_empleado;
        EXIT WHEN c_socio%NOTFOUND;
        -- Ejemplo de uso:
        dbms_output.put_line(v_empleado.pnombre || ' ' || v_empleado.appaterno);
    END LOOP;
    CLOSE c_socio;
END;

--cursores for
DECLARE
    cursor c_socio is 
        select * from dual;
    type empleado_rec is record (
        pnombre VARCHAR2(20),
        appaterno VARCHAR2(20),
        apmaterno VARCHAR2(20)
    );
BEGIN
    FOR empleado_rec IN c_socio LOOP
        --contenido
    END LOOP;
END;

--Funciones: 

create or replace function f_edad(p_fecha)
return number 
is
    v_edad number;
begin
    select trunc(months_between(p_fecha, sysdate)/12) into v_edad from dual;
    return v_edad;
end;

--Procedimientos:
create or replace procedure pr_generar_correo
is
    v_correo VARCHAR2(100);
    cursor c_socio is 
        select * from dual; --tabla a eleccion
    type empleado_rec is record (
        pnombre VARCHAR2(20),
        appaterno VARCHAR2(20),
        apmaterno VARCHAR2(20)
    );
begin
    form empleado_rec in c_socio loop
        v_correo :=empleado_rec.pnombre ||' '||empleado_rec.appaterno||'@gmail.com';
        v_correo:=lower(v_correo);
        update socio set correo v_correo where rut= empleado_rec.rut;
    end loop;

end;
--ejecutar el procedimiento
execute pr_generar_correo;

--Triggers: Script que se ejecutara antes de que se realice una accion. 
create or replace trigger tr_auditoria_empleado
after insert or update 
for each row 
begin 
    insert into auditoria_empleado --tabla auditoria
    values (:new.rut, :new.pnombre, :new.appaterno, :new.apmaterno, sysdate); --new hace referencia a los nuevos valores que se estan insertando

end;

--Paquetes: conjunto de procedimientos y funciones
create or replace package pk_pruebas
is 
    function f_edad(p_fecha) return number;
end;
create or replace package body pk_pruebas
is 
    --Dentro del body se hace la funcion desde 0. 
    function f_edad(p_fecha) return number
    is
        v_edad number;
    begin
        select trunc(months_between(p_fecha, sysdate)/12) into v_edad from dual;
        return v_edad;
    end;
end;