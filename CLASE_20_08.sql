--CLASE 20-08
select * from socio order by 1;
--Bloquye anonimo
set SERVEROUTPUT on;


declare 
   /* Ejemplo: v_temp VARCHAR2(10);
    v_edad number(2,1); -- <--Primer Digito la cantidad de digitos, el segundo el numero de decimales*/
    
        --Definir un record: sirve como un diccionario de datos
        
    type tipo_socio is record(
        pnombre socio.pnombre%type,
        appaterno socio.APPATERNO%type,
        fecha_nacimiento Date
    );
    v_socio tipo_socio;
    --Variables
    v_pnombre socio.PNOMBRE%TYPE;
    v_appaterno socio.APPATERNO%TYPE;
    v_fecha_nac socio.FECHA_NACIMIENTO%TYPE;
    v_edad number(3);
    
BEGIN
    
    /*Ejemplo: v_temp:= 'Hola';
    v_edad:=1.5;
    DBMS_OUTPUT.PUT_LINE('Primer Bloque: '||v_temp);
    DBMS_OUTPUT.PUT_LINE('Primer Bloque: '||v_edad);*/
    
    select pnombre, appaterno, FECHA_NACIMIENTO 
    --into v_pnombre,v_appaterno,v_fecha_nac
    into v_socio
    from SOCIO 
    where NRO_SOCIO=1;
    
    DBMS_OUTPUT.PUT_LINE('Primer Nombre: '||v_pnombre||' Apellido Paterno: '||v_appaterno);
    DBMS_OUTPUT.PUT_LINE('Primer Nombre: '||v_pnombre||' '||v_appaterno);
    DBMS_OUTPUT.PUT_LINE('Primer Nombre: '||v_fecha_nac);
    v_edad:=months_between(sysdate, v_fecha_nac)/12;
    DBMS_OUTPUT.PUT_LINE('Primer Nombre: '||v_edad);
    
    DBMS_OUTPUT.PUT_LINE('Primer Nombre: '||v_socio.pnombre||' '||v_socio.appaterno||' '||v_socio.fecha_nacimiento);
end;



--Cursores: Usando LOOP
DECLARE
    --Definir CURSOR
    cursor c_socio is 
        select NRO_SOCIO ,PNOMBRE,APPATERNO from socio;
    --Definir Record
    type v_socio is record(
        nro_socio socio.NRO_SOCIO%TYPE,
        pnombre socio.PNOMBRE%TYPE,
        appaterno socio.APPATERNO%TYPE
    );
    r_socio v_socio;

BEGIN
    open c_socio;
        loop
            fetch c_socio into r_socio;
            exit when c_socio%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Numero de Socio: '||r_socio.nro_socio||' Nombre: '||r_socio.pnombre||' Apellido paterno: '||r_socio.appaterno);
        end loop;
    close c_socio;
end;
/


--Cursor 2: Usando Ciclo For
DECLARE
    --Definir CURSOR
    cursor c_socio is 
        select NRO_SOCIO ,PNOMBRE,APPATERNO from socio;
BEGIN
    for reg_socio in c_socio LOOP
        DBMS_OUTPUT.PUT_LINE('Numero de Socio: '||reg_socio.nro_socio||' Nombre: '||reg_socio.pnombre||' Apellido paterno: '||reg_socio.appaterno);
    end loop;
end;
/


DECLARE
    cursor c_socios IS 
        select 
            s.NUMRUN,
            s.DVRUN,
            s.PNOMBRE,
            s.SNOMBRE,
            s.APPATERNO,
            s.APMATERNO,
            s.FECHA_INSCRIPCION,
            s.COD_TIPO_SOCIO,
            ts.NOMBRE_TIPO_SOCIO,
            count(*) as cantidad_inverson
        from socio s
        join tipo_socio ts on s.COD_TIPO_SOCIO=ts.COD_TIPO_SOCIO
        join PRODUCTO_INVERSION_SOCIO pis on pis.NRO_SOCIO=s.NRO_SOCIO
        group by s.NRO_SOCIO,
            s.NUMRUN,
            s.DVRUN,
            s.PNOMBRE,
            s.SNOMBRE,
            s.APPATERNO,
            s.APMATERNO,
            s.FECHA_INSCRIPCION,
            s.COD_TIPO_SOCIO,
            ts.NOMBRE_TIPO_SOCIO;
    v_nombre VARCHAR2(100);
    v_numrut varchar2(15);
    v_antiguedad number;
    v_cantidad_productos number;
BEGIN

    for re_socio in c_socios loop
        v_numrut:=re_socio.NUMRUN||'-'||re_socio.DVRUN;
        v_nombre:=upper(re_socio.PNOMBRE||' '||re_socio.SNOMBRE||' '||re_socio.APPATERNO||' '||re_socio.APMATERNO);
        v_antiguedad:=trunc(months_between(sysdate,re_socio.FECHA_INSCRIPCION)/12);

        
        DBMS_OUTPUT.PUT_LINE('--------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Rut Socio: '||v_numrut);
        DBMS_OUTPUT.PUT_LINE('Nombre Completo: '||v_nombre);
        DBMS_OUTPUT.PUT_LINE('Antiguedad: '||v_antiguedad);
        DBMS_OUTPUT.PUT_LINE('Codigo Tipo Socio: '||re_socio.NOMBRE_TIPO_SOCIO);
        DBMS_OUTPUT.PUT_LINE('Cantidad de Inversión: '||re_socio.cantidad_inverson);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    end loop;
END;
/


DECLARE
    cursor c_socios IS 
        select 
            s.NRO_SOCIO,
            s.NUMRUN,
            s.DVRUN,
            s.PNOMBRE,
            s.SNOMBRE,
            s.APPATERNO,
            s.APMATERNO,
            s.FECHA_INSCRIPCION,
            s.COD_TIPO_SOCIO,
            ts.NOMBRE_TIPO_SOCIO,
            count(*) as cantidad_inverson
        from socio s
        join tipo_socio ts on s.COD_TIPO_SOCIO=ts.COD_TIPO_SOCIO;
    v_nombre VARCHAR2(100);
    v_numrut varchar2(15);
    v_antiguedad number;
    v_cantidad_productos number;
    v_cantidad_creditos number;
BEGIN

    for re_socio in c_socios loop
        v_numrut:=re_socio.NUMRUN||'-'||re_socio.DVRUN;
        v_nombre:=upper(re_socio.PNOMBRE||' '||re_socio.SNOMBRE||' '||re_socio.APPATERNO||' '||re_socio.APMATERNO);
        v_antiguedad:=trunc(months_between(sysdate,re_socio.FECHA_INSCRIPCION)/12);

        select count(*) into v_cantidad_productos
        from PRODUCTO_INVERSION_SOCIO
        where NRO_SOCIO=re_socio.nro_socio;

        select count(*)
        into v_cantidad_creditos 
        from CREDITO_SOCIO 
        where 
        
        DBMS_OUTPUT.PUT_LINE('--------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Rut Socio: '||v_numrut);
        DBMS_OUTPUT.PUT_LINE('Nombre Completo: '||v_nombre);
        DBMS_OUTPUT.PUT_LINE('Antiguedad: '||v_antiguedad);
        DBMS_OUTPUT.PUT_LINE('Codigo Tipo Socio: '||re_socio.NOMBRE_TIPO_SOCIO);
        DBMS_OUTPUT.PUT_LINE('Cantidad de Inversión: '||re_socio.cantidad_inverson);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    end loop;
END;
/

