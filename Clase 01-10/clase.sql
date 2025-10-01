select * from WAREHOUSES;
select * from INVENTORIES;
select * from PRODUCT_INFORMATION;

select product_id, PRODUCT_NAME from PRODUCT_INFORMATION;
select WAREHOUSE_NAME from WAREHOUSES;

select product_id, PRODUCT_NAME,inv.QUANTITY_ON_HAND, WAREHOUSE_NAME from PRODUCT_INFORMATION pi 
join INVENTORIES inv USING(PRODUCT_ID) 
join WAREHOUSES w on w.WAREHOUSE_ID=inv.WAREHOUSE_ID
where PRODUCT_ID=3108;

--Crear 3 funciones:
--0: En un package crear las sigientes funciones: 
--1: Un funcion que reciba como parametro un ID_Product y un id warehouse y luego que retorne la cantidad de productos que tiene ese tipo en el almacen.

--2. Una funcion que reciba como parameros un idProduct y retorne la cantidad total de productos que hay en el sistema completo

create or REPLACE PACKAGE pckg_funciones as 
    FUNCTION fnc_cant_Prod(p_Product_ID number, p_id_warehouse number)
        return number;
    FUNCTION fnc_total_Prod(p_Product_ID number)
        return number;
end pckg_funciones;
/

create or REPLACE PACKAGE BODY pckg_funciones as
    FUNCTION fnc_cant_Prod(p_Product_ID number,p_id_warehouse number)
    return number 
    is 
        v_cant_prod number;
        v_exist number;
    BEGIN
        --Validar si existe el Producto
        select count(*) 
        into v_exist
        from PRODUCT_INFORMATION
        where p_Product_ID = PRODUCT_ID;

        SELECT count(*)
        into v_exist
        from WAREHOUSES
        where p_id_warehouse=WAREHOUSE_ID;

        if v_exist = 0 then 
            RAISE_APPLICATION_ERROR(-20001, 'El producto o almacen no existe...');
            DBMS_OUTPUT.PUT_LINE('El producto o almacen no existe...');
        end IF;

        select
            nvl(sum(QUANTITY_ON_HAND),0)
        into v_cant_prod
        from INVENTORIES
        where p_Product_ID = PRODUCT_ID and p_id_warehouse=WAREHOUSE_ID;
        return v_cant_prod;
    EXCEPTION
        when others then
            DBMS_OUTPUT.PUT_LINE('Error: '||SQLERRM);
            RETURN 0;
    END fnc_cant_Prod;

    --Funcion 2:
    FUNCTION fnc_total_Prod(p_Product_ID number)
    return number
    is
        v_total_prod number;
    begin
        select 
            nvl(sum(QUANTITY_ON_HAND),0)
        into v_total_prod
        from INVENTORIES
        where p_Product_ID=PRODUCT_ID;

        return v_total_prod;
    EXCEPTION
        when others then
            DBMS_OUTPUT.PUT_LINE('El producto o almacen no existe...');
    END fnc_total_Prod;    
end pckg_funciones;
/
set SERVEROUTPUT on;

select PCKG_FUNCIONES.FNC_CANT_PROD(3108, 15)from dual;

select PCKG_FUNCIONES.FNC_TOTAL_PROD(3108) from dual;