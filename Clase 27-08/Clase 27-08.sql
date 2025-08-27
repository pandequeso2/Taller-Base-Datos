/*Clase 27-08: FUnciones y Procedimientos.*/


/*Funciones: */

--Habilitar consola


create or replace FUNCTION fn_edad(p_fecha Date)
return NUMBER 
is 
    v_edad Number(3);
begin 
    v_edad:=trunc(MONTHs_between(sysdate, p_fecha)/12);
    return v_edad;
end;
/
select fn_edad('27-08-2000') from dual;/
select 
    NRO_SOCIO,
    PNOMBRE, 
    fn_edad(FECHA_NACIMIENTO) "Edad"
from socio;/

/*Otra Funcion*/
/*Funcion para hacer el nombre completo*/
create or REPLACE FUNCTION fn_nombreCompleto(p_nro_socio socio.NRO_SOCIO%TYPE)
return varchar2
is
    v_nombre socio.PNOMBRE%TYPE;
    v_sombre socio.SNOMBRE%TYPE;
    v_appaterno socio.APPATERNO%TYPE;
    v_apmaterno socio.APMATERNO%TYPE;
    v_nombreCompleto varchar2(100);
    
begin
    select 
        PNOMBRE,SNOMBRE,APPATERNO,APMATERNO
    into v_nombre,v_sombre,v_appaterno,v_apmaterno
    from socio
    where NRO_SOCIO= p_nro_socio;

    v_nombreCompleto:=v_nombre||' '||v_sombre||' '||v_appaterno||' '||v_apmaterno;
    return v_nombreCompleto;

    EXCEPTION
        when NO_DATA_FOUND THEN RETURN '--Sin Datos';
end;
/
/*Usar la funcion*/
select 
    NRO_SOCIO,
    FN_NOMBRECOMPLETO(NRO_SOCIO)
from socio;


--Procedimientos:



create or replace PROCEDURE sp_generar_correo
is 
    v_correo varchar2(100);
    cursor c_socio is
        select * from socio;
begin
    for reg_socio in c_socio loop
        v_correo:=substr(reg_socio.PNOMBRE,0,3)||'.'||reg_socio.APPATERNO||'.'||
        substr(reg_socio.APMATERNO,0,3)||'.'||
        case 
            when reg_socio.SNOMBRE is null then 2
            else 1
        end||'@Coopera.cl';

        v_correo:=lower(v_correo);
        --Otro Bloque para actualizar los datos
        update SOCIO
        set CORREO=v_correo where NRO_SOCIO=reg_socio.NRO_SOCIO;        


    end loop;
end;
/
select * from socio;


EXECUTE SP_GENERAR_CORREO;








