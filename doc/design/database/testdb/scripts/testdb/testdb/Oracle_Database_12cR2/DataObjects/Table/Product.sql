--CREATE TABLE product (
--    id               INTEGER NOT NULL,
--    category         CHAR 
----  WARNING: CHAR size not specified 
--    ,
--    name             CHAR 
--  WARNING: CHAR size not specified 
--    ,
--    retail_price     NUMBER,
--    discounted_price NUMBER,
--    discount_percent INTEGER,
--    availability     NUMBER
--);

--CREATE UNIQUE INDEX product__idx ON
--    product (
--        id
--    ASC );
    
    
    
    
CREATE TABLE product (
    id               INT8 NOT NULL,
    category         VARCHAR,
    name             VARCHAR,
    retail_price     FLOAT8,
    discounted_price FLOAT8,
    discount_percent INT4,
    availability     BOOL
);
