--Needed for JPA/hibernate
CREATE SEQUENCE HIBERNATE_SEQUENCE MAXVALUE 9223372036854775807 NO CYCLE;
--Example
CREATE TABLE EXAMPLEAPP_WIDGET  (
	ID BIGINT  NOT NULL PRIMARY KEY ,
	NAME VARCHAR(50)
);
