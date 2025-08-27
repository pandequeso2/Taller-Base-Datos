/*Actividad*/
--Cantidad de Productos

create or replace FUNCTION fn_cant_productos(p_nro_socio socio.NRO_SOCIO%type)
return Number
is
    v_cantidad_productos Number(3);
begin
    select count(NRO_SOCIO) into v_cantidad_productos from producto_inversion_socio where NRO_SOCIO=p_nro_socio;
    return v_cantidad_productos;
end;
/
select NRO_SOCIO,fn_cant_productos(NRO_SOCIO), FN_NOMBRECOMPLETO(NRO_SOCIO) from socio order by 1 desc;
--Cantidad de Creditos

create or replace FUNCTION fn_cant_creditos(p_nro_socio socio.NRO_SOCIO%Type)
return NUMBER
IS
    v_cantidad_creditos number;
BEGIN
    select count(NRO_SOCIO) into v_cantidad_creditos from CREDITO_SOCIO where NRO_SOCIO=p_nro_socio;
    return v_cantidad_creditos;
end;
/

select NRO_SOCIO, FN_CANT_creditos(NRO_SOCIO), FN_NOMBRECOMPLETO(NRO_SOCIO) from CREDITO_SOCIO order by 2 desc;

--Funcion que muestre la cantidad de cuotas pagadas según el nro_socio

create or REPLACE FUNCTION fn_canidad_cuotas_pagadas(p_nro_solic_credito CREDITO_SOCIO.nro_solic_credito%type)
return NUMBER
IS
    v_cantidad number(3);
BEGIN
    SELECT count(MONTO_PAGADO) INTO v_cantidad from CUOTA_CREDITO_SOCIO where NRO_SOLIC_CREDITO=p_nro_solic_credito;
    return v_cantidad;
end;
/
select nro_solic_credito,FN_CANIDAD_CUOTAS_PAGADAS(NRO_SOLIC_CREDITO) from CREDITO_SOCIO;
