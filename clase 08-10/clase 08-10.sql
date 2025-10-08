-- CREAMOS EL PACKAGE
CREATE OR REPLACE PACKAGE pkg_inventario AS
    FUNCTION fn_stock_in_warehouse(
        p_product_id NUMBER,
        p_warehouse_id NUMBER
    ) RETURN NUMBER;
    
    FUNCTION fn_stock_total(
        p_product_id NUMBER
    ) RETURN NUMBER;
    
    FUNCTION fn_pct_distribution(
        p_product_id NUMBER,
        p_warehouse_id NUMBER
    ) RETURN NUMBER;
END;
/
--CREAMOS EL BODY
CREATE OR REPLACE PACKAGE BODY pkg_inventario AS
--Escribir errores prsonalizados...
    e_product_not_found EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_product_not_found, -20001);
    e_warehouse_not_found EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_warehouse_not_found, -20002);
    FUNCTION fn_stock_in_warehouse(
        p_product_id NUMBER,
        p_warehouse_id NUMBER
    ) RETURN NUMBER
    IS
        v_qty NUMBER;
        v_exist NUMBER;
        
    BEGIN
        
        --validamos si existe el producto
        -- Si v_exist es 0, no existe. SI es 1 existe.
        SELECT COUNT(*)
        INTO v_exist
        FROM PRODUCT_INFORMATION
        WHERE product_id = p_product_id;
        
        IF v_exist = 0 THEN
            RAISE_APPLICATION_ERROR(-20001,'ERROR: El producto no existe: ' || p_product_id);
        END IF;
        
        SELECT COUNT(*)
        INTO v_exist
        FROM WAREHOUSES
        WHERE warehouse_id = p_warehouse_id;
        
        IF v_exist = 0 THEN
            RAISE_APPLICATION_ERROR(-20002,'ERROR: El almacen no existe: ' || p_warehouse_id);
        END IF;
    
        SELECT QUANTITY_ON_HAND
        INTO v_qty
        FROM inventories
        WHERE 
            product_id = p_product_id
        AND
            warehouse_id = p_warehouse_id;
        DBMS_OUTPUT.PUT_LINE(v_qty);
        RETURN v_qty;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No existe producto en ese almacen.');
            RETURN 0;
        WHEN e_product_not_found THEN
            DBMS_OUTPUT.PUT_LINE('Hay un error: ' || SQLERRM);
            RETURN -1;
        WHEN e_warehouse_not_found THEN
            DBMS_OUTPUT.PUT_LINE('Hay un error: ' || SQLERRM);
            RETURN -1;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Hay un error' || SQLERRM);
    END;
    
    FUNCTION fn_stock_total(
        p_product_id NUMBER
    ) RETURN NUMBER
    IS
        v_qty NUMBER;
    BEGIN
        SELECT SUM(QUANTITY_ON_HAND)
        INTO v_qty
        FROM inventories
        WHERE product_id = p_product_id;
        
        RETURN v_qty;
    END;
    --tercera funcion
    FUNCTION fn_pct_distribution(
        p_product_id NUMBER,
        p_warehouse_id NUMBER
    ) RETURN NUMBER
    IS
        v_stock_warehouse NUMBER;
        v_stock_total NUMBER;
        v_pct NUMBER;
    BEGIN
        v_stock_warehouse := fn_stock_in_warehouse(p_product_id,p_warehouse_id);
        v_stock_total := fn_stock_total(p_product_id);
        v_pct := v_stock_warehouse * 100 /v_stock_total;
        RETURN ROUND(v_pct,2);
    END;
    /
    
    create PROCEDURE pr_reporte(p_product_id number)
    is 
        v_porcentaje number;
        v_product_name varchar2(100);
        cursor c_almacen IS
            select * from WAREHOUSES;
    begin
        SELECT PRODUCT_NAME into v_product_name from PRODUCT_INFORMATION where PRODUCT_ID=p_product_id; 
        EXECUTE IMMEDIATE 'truncate table reportes';
        for cont in c_almacen loop
            v_porcentaje:=PCKG_FUNCIONES.FN_PCT_DISTRIBUTION(p_product_id, cont.warehouse_id);
            INSERT into REPORTES values(SEQ_REPORTE.nextval, cont.warehouse_id, cont.WAREHOUSE_NAME, p_product_id, v_product_name, v_porcentaje);
            
        end loop;
    end;
    /
END;
/

select pkg_inventario.fn_pct_distribution(3108,2) from dual;

--PREGUNTAR POR EL STOCK EN DEL 3108 en bodega 1

select pkg_inventario.fn_stock_in_warehouse(3108,9) from dual;


--PRODUCTO NO EXISTE
select pkg_inventario.fn_stock_in_warehouse(1,2) from dual;

--ALMACEN NO EXISTE
select pkg_inventario.fn_stock_in_warehouse(3108,32) from dual;
--bloque anonimo que recorra todos los almacenes 
declare 
    v_porcentaje number;
    cursor c_almacen IS
        select * from WAREHOUSES;
begin 
    for cont in c_almacen loop
        DBMS_OUTPUT.PUT_LINE('Almacen: '||cont.WAREHOUSE_ID||' '|| cont.WAREHOUSE_NAME);
        v_porcentaje:=PCKG_FUNCIONES.FN_PCT_DISTRIBUTION(3108, cont.warehouse_id);
        DBMS_OUTPUT.PUT_LINE('Porcentaje: '|| round(v_porcentaje)||'%');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------');

    
    end loop;
end;
/


EXECUTE pr_reporte(3108);

--Crear tabla para almacenar 

create SEQUENCE seq_reporte start with 1 INCREMENT by 1;
create table reportes(
    report_id number primary key,
    warehouse_id number,
    WAREHOUSE_NAME varchar2(50),
    product_id number,
    product_name VARCHAR2(100),
    pc_disribution number(5,2)
);

SELECT * FROM REPORTES;