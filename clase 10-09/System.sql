alter session set "_oracle_script"= true;

-- Carreras
CREATE TABLE carreras (
  id_carrera NUMBER PRIMARY KEY,
  nombre     VARCHAR2(100) NOT NULL
);
 
 
INSERT INTO carreras (id_carrera, nombre) VALUES (1, 'Ingeniería Informática');
INSERT INTO carreras (id_carrera, nombre) VALUES (2, 'Analista Programador');
INSERT INTO carreras (id_carrera, nombre) VALUES (3, 'Telecomunicaciones');
COMMIT;
 
 
-- Estudiantes
CREATE TABLE estudiantes (
  id_estudiante NUMBER PRIMARY KEY,
  nombre        VARCHAR2(100) NOT NULL,
  fecha_nac    DATE NOT NULL,
  id_carrera    NUMBER NOT NULL
  -- OJO!!!: NO ponemos FK aquí para forzar nuestro manejo propio del error.
);
 
-- Registro de errores
CREATE TABLE registro_errores (
  id_registro   NUMBER PRIMARY KEY,
  fecha_hora    TIMESTAMP DEFAULT SYSTIMESTAMP,
  detalle_error VARCHAR2(4000),
  nombre_est    VARCHAR2(100),
  fecha_nac_est DATE,
  id_carrera    NUMBER
);
 
-- Secuencias
CREATE SEQUENCE seq_estudiante START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_reg_error  START WITH 1 INCREMENT BY 1 NOCACHE;
 

set SERVEROUTPUT on;
DECLARE
    v_id_estudiante estudiantes.id_estudiante%TYPE;
    v_nombre varchar2(100);
    v_fecha_nac date;
    v_id_carrera estudiantes.id_carrera%TYPE;
    v_edad number;
    v_existe number;

    --dECLARAR NUEVO ERROR
    excepcion_menor_edad EXCEPTION;
    PRAGMA EXCEPTION_INIT(excepcion_menor_edad, -20001);
    v_mensaje_error VARCHAR2(4000);
    ex_carrera_notFound EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_carrera_notFound,-20002);
BEGIN
    v_id_estudiante:= 1;
    v_nombre:= 'Lucho';
    v_fecha_nac:= TO_DATE('10-09-2000', 'DD-MM-YYYY');
    v_id_carrera:= 4;
    

    v_edad:= TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nac) / 12);
    DBMS_OUTPUT.PUT_LINE('Edad: ' || v_edad);
    --Si la edad es menor a 18, Lanzara el error de 'El estudiante no puede ser menor de edad'
    IF v_edad < 18 then 
        RAISE_APPLICATION_ERROR(-20001,'El estudiante no puede ser menor de edad');

    end if;
    --Ve si la carrera existe
    select count(*)
    into v_existe
    from CARRERAS
    where ID_CARRERA=v_id_carrera;
    -- Si no existe la carrera con el id 4, lanzara el eror 'La carrera no existe'
    IF v_existe = 0 then 
        RAISE_APPLICATION_ERROR(-20002, 'La carrera no existe');
    end if;
    dbms_output.PUT_LINE('FIn del programa...');
EXCEPTION
    WHEN excepcion_menor_edad THEN
        -- Manejo del error
        DBMS_OUTPUT.PUT_LINE('Error: excepcion menor de edad');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        DBMS_OUTPUT.PUT_LINE(SQLCODE);
        v_mensaje_error:= SQLERRM;

        insert into REGISTRO_ERRORES values (SEQ_REG_ERROR.nextval, SYSTIMESTAMP,v_mensaje_error,
                                            v_nombre,v_fecha_nac,v_id_carrera);
    when ex_carrera_notFound then 
        v_mensaje_error:=SQLERRM;
        insert into REGISTRO_ERRORES values (SEQ_REG_ERROR.nextval, SYSTIMESTAMP,v_mensaje_error,
                                            v_nombre,v_fecha_nac,v_id_carrera);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Otro error');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        DBMS_OUTPUT.PUT_LINE(SQLCODE);
END;
/

SELECT * FROM REGISTRO_ERRORES;