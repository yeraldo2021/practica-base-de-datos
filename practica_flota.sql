create schema flota;

create table flota.vehiculo (
matricula varchar(10) primary key,
codigo_modelo int not null,
codigo_color int not null,
fecha_compra date not null,
km_vehiculo int not null
);

create table flota.revision(
codigo_revision serial primary key,
matricula varchar(10) not null,
codigo_moneda smallint not null,
km_revision int not null,
fecha_revision date not null,
importe_revision float not null
);

create table flota.moneda(
codigo_moneda serial primary key,
nombre_moneda varchar(50) not null
);

create table flota.color(
codigo_color serial primary key,
nombre_color varchar(50) not null
);

create table flota.poliza(
codigo_poliza serial primary key,
codigo_aseguradora smallint not null,
matricula varchar(10) not null,
fecha_alta_poliza date not null
);

create table flota.aseguradora(
codigo_aseguradora serial primary key,
nombre_aseguradora varchar(80) not null
);

create table flota.modelo(
codigo_modelo serial primary key,
codigo_marca int not null,
nombre_modelo varchar(80) not null
);

create table flota.marca(
codigo_marca serial primary key,
grupo_marca int not null,
nombre_marca varchar(80) not null
);

create table flota.grupo(
codigo_grupo serial primary key,
nombre_grupo varchar(80) not null
);

alter table flota.vehiculo add constraint fk_codigo_modelo foreign key (codigo_modelo) references flota.modelo(codigo_modelo); 
alter table flota.vehiculo add constraint fk_codigo_color foreign key (codigo_color) references flota.color(codigo_color);

alter table flota.revision add constraint fk_matricula foreign key (matricula) references flota.vehiculo(matricula);
alter table flota.revision add constraint fk_codigo_moneda foreign key (codigo_moneda) references flota.moneda(codigo_moneda);

alter table flota.poliza add constraint fk_codigo_aseguradora foreign key (codigo_aseguradora) references flota.aseguradora(codigo_aseguradora);
alter table flota.poliza add constraint fk_matricula foreign key (matricula) references flota.vehiculo(matricula);

alter table flota.modelo add constraint fk_codigo_marca foreign key (codigo_marca) references flota.marca(codigo_marca);

alter table flota.marca add constraint fk_grupo_marca foreign key (grupo_marca) references flota.grupo(codigo_grupo);

CREATE TABLE flota.coches (
	matricula varchar(50) NULL,
	grupo varchar(50) NULL,
	marca varchar(50) NULL,
	modelo varchar(50) NULL,
	fecha_compra date NULL,
	color varchar(50) NULL,
	aseguradora varchar(50) NULL,
	n_poliza int4 NULL,
	fecha_alta_seguro date NULL,
	importe_revision float4 NULL,
	moneda varchar(50) NULL,
	kms_revision int4 NULL,
	fecha_revision date NULL,
	kms_totales int4 NULL
);

insert into flota.grupo (nombre_grupo)
select grupo from flota.coches group by grupo;

insert into flota.color (nombre_color)
select color from flota.coches group by color;

insert into flota.moneda (nombre_moneda)
select moneda from flota.coches group by moneda;

insert into flota.aseguradora (nombre_aseguradora)
select aseguradora from flota.coches group by aseguradora;


insert into flota.marca (grupo_marca, nombre_marca)
select 
	flota.grupo.codigo_grupo, 
	flota.coches.marca 
from flota.coches 
inner join flota.grupo on flota.grupo.nombre_grupo = flota.coches.grupo 
group by flota.grupo.codigo_grupo, flota.coches.marca;


insert into flota.modelo (codigo_marca, nombre_modelo)
select flota.marca.codigo_marca, modelo from flota.coches
inner join flota.grupo on flota.grupo.nombre_grupo = flota.coches.grupo 
inner join flota.marca on flota.marca.nombre_marca = flota.coches.marca 
group by flota.grupo.codigo_grupo, flota.marca.codigo_marca, flota.coches.modelo;

insert into flota.vehiculo (matricula, codigo_modelo, codigo_color, fecha_compra, km_vehiculo)
select matricula, flota.modelo.codigo_modelo, flota.color.codigo_color, fecha_compra, kms_totales from flota.coches 
inner join flota.grupo on flota.grupo.nombre_grupo = flota.coches.grupo 
inner join flota.marca on flota.marca.nombre_marca = flota.coches.marca 
inner join flota.modelo on flota.modelo.nombre_modelo = flota.coches.modelo 
inner join flota.color on flota.color.nombre_color = flota.coches.color 
group by matricula, flota.modelo.codigo_modelo, flota.color.codigo_color, fecha_compra, kms_totales;

insert into flota.poliza (codigo_poliza, codigo_aseguradora, matricula, fecha_alta_poliza)
select flota.coches.n_poliza, flota.aseguradora.codigo_aseguradora, flota.coches.matricula, flota.coches.fecha_alta_seguro from flota.coches
inner join flota.aseguradora on flota.aseguradora.nombre_aseguradora = flota.coches.aseguradora 
group by flota.coches.n_poliza, flota.aseguradora.codigo_aseguradora, flota.coches.matricula, flota.coches.fecha_alta_seguro
order by flota.coches.matricula, flota.coches.n_poliza;

insert into flota.revision (matricula, codigo_moneda, km_revision, fecha_revision, importe_revision)
select	flota.coches.matricula, flota.moneda.codigo_moneda, flota.coches.kms_revision, flota.coches.fecha_revision, round(flota.coches.importe_revision::decimal,2) from flota.coches
inner join flota.moneda on flota.moneda.nombre_moneda  = flota.coches.moneda 
group by flota.coches.matricula, flota.moneda.codigo_moneda, flota.coches.kms_revision, flota.coches.fecha_revision, flota.coches.importe_revision
order by flota.coches.matricula;


