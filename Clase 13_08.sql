
/*
Select  
    pnombre,appaterno,fecha_nacimiento,TIPO_SOCIO.NOMBRE_TIPO_SOCIO
from socio 
join TIPO_SOCIO using (COD_TIPO_SOCIO);
 Forma alterna de hacer un join */

select
    s.pnombre,s.appaterno,s.fecha_nacimiento,ts.NOMBRE_TIPO_SOCIO
from SOCIO s
join TIPO_SOCIO ts on ts.COD_TIPO_SOCIO=s.COD_TIPO_SOCIO;

set SERVEROUTPUT =true;

DECLARE
    CURSOR c_socio IS 
        SELECT * FROM SOCIO;
    v_pnombre varchar2(20);
    v_snombre varchar2(20);
    v_apapellido varchar2(20);
    v_amapellido varchar2(20);
    v_nombre_completo varchar2(120);
    v_edad number;
    v_fecha_nac Date;
BEGIN

    SELECT pnombre,snombre,appaterno,APMATERNO
    into v_pnombre,v_snombre,v_apapellido,v_amapellido
    from SOCIO
    where NRO_SOCIO=10;

    DBMS_OUTPUT.PUT_LINE('Tengo: '||v_pnombre);
    DBMS_OUTPUT.PUT_LINE('Tengo: '||v_snombre);
    DBMS_OUTPUT.PUT_LINE('Tengo: '||v_apapellido);
    DBMS_OUTPUT.PUT_LINE('Tengo: '||v_amapellido);

    v_nombre_completo:=v_pnombre||' '||v_snombre||' '||v_apapellido||' '||v_amapellido;
    DBMS_OUTPUT.PUT_LINE('Tengo: '||v_nombre_completo);

    SELECT
        FECHA_NACIMIENTO
    into v_fecha_nac 
    from socio 
    where NRO_SOCIO=10;

    v_edad:= EXTRACT(year from sysdate)- EXTRACT(year from v_fecha_nac);    --Nos devuelve 47
    v_edad:=Trunc(MONTHS_BETWEEN(sysdate,v_fecha_nac)/12); --Nos devuelve 46
    DBMS_OUTPUT.PUT_LINE(v_edad);
    /*if v_edad>40 then:
        DBMS_OUTPUT.PUT_LINE('Oli');
    --ELSIF Otras condiciones
    else
        DBMS_OUTPUT.PUT_LINE('Chao');
    end if;*/
    FOR reg_socio in c_socio LOOP
        DBMS_OUTPUT.PUT_LINE(reg_socio.v_pnombre||' '||reg_socio.v_snombre||' '||reg_socio.v_apapellido||' '||reg_socio.v_amapellido);
    end loop;


END;
/