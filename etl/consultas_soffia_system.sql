
-- agencias: puntos de comercio
create table dim_agencia(
    dim_agencia_id int identity(1,1) primary key, 
    agencia_id int,
    agencia_codigo varchar(200),
    agencia_nombre varchar(200),
    agencia_ubicacion varchar(200),
    agencia_departamento varchar(100),
    agencia_provincia varchar(100),
    agencia_distrito varchar(100)
);
GO
SET IDENTITY_INSERT dim_agencia off; 
GO
insert into dim_agencia(agencia_id,agencia_codigo,agencia_nombre,agencia_ubicacion,agencia_departamento,agencia_provincia,agencia_distrito)
select 
    idAgencia,
    codAgencia,
    upper(nombreAgencia),
    upper(ubicacion),
    (select upper(denominacion) from Ubigeo where codDpto=Agencia.codDpto and codProv='00' and codDist='00') as departamento,
    (select upper(denominacion) from Ubigeo where codDpto=Agencia.codDpto and codProv=Agencia.codProv and codDist='00') as provincia,
    (select upper(denominacion) from Ubigeo where codDpto=Agencia.codDpto and codProv=Agencia.codProv and codDist=Agencia.codDist) as distrito
    from Agencia where estado=1;
GO
select * from dim_agencia;



-- //////////////////////////////////////////////////////


-- agencias: empelados que ha contratado la agencia (todos)
create table dim_empleado(
    dim_empleado_id int identity(1,1) primary key,
    agencia_id int,
    agencia_codigo varchar(200),
    agencia_nombre varchar(200),
    agencia_ubicacion varchar(200),
    agencia_departamento varchar(100),
    agencia_provincia varchar(100),
    agencia_distrito varchar(100),
    empleado_id int,
    empleado_nombre varchar(200),
    empleado_fecha_nacimiento Date,
    empleado_cargo varchar(200) 
);
GO
SET IDENTITY_INSERT dim_empleado off; 
GO
insert into dim_empleado select 
-- agencia:
    Agencia.idAgencia,
    Agencia.codAgencia,
    upper(Agencia.nombreAgencia),
    upper(Agencia.ubicacion),
    (select upper(denominacion) from Ubigeo where codDpto=Agencia.codDpto and codProv='00' and codDist='00') as departamento,
    (select upper(denominacion) from Ubigeo where codDpto=Agencia.codDpto and codProv=Agencia.codProv and codDist='00') as provincia,
    (select upper(denominacion) from Ubigeo where codDpto=Agencia.codDpto and codProv=Agencia.codProv and codDist=Agencia.codDist) as distrito,
-- empleado:
    Empleado.idUsuario,
    upper(concat(nombres,', ',apPaterno,' ', apMaterno)) as empleado_nombre, 
    Empleado.fechaNacimiento,
    (select upper(nombreCargo) from Cargo where estado=1 and idCargo=Empleado.idCargo) as nombreCargo
from EmpleadoPorAgencia
inner join Agencia on (EmpleadoPorAgencia.idAgencia = Agencia.idAgencia)
inner join Empleado on (EmpleadoPorAgencia.idEmpleado = Empleado.idEmpleado)
where Agencia.estado=1 and EmpleadoPorAgencia.estado=1;
GO
select * from dim_empleado;



-- //////////////////////////////////////////////////////


-- clientes: solamente clientes que disponen de una cuenta crédito. incluyen a p. jurídica, natural
create table dim_cliente(
    dim_cliente_id int identity(1,1) primary key,
    cliente_id int,
    cuenta_id int,
    cliente_aval varchar(200),
    cliente_estado varchar(200),
    cliente_tipo varchar(200),
    cliente_labora_empresa_id int,

    cliente_labora_email varchar(100),
    cliente_labora_ruc varchar(100),
    cliente_labora_razon_social varchar(100),
    cliente_labora_nombre_comercial varchar(100),
    cliente_labora_tipo varchar(100),
    cliente_labora_giro_negocio varchar(100),
    cliente_labora_cargo_laboral varchar(100),

    cliente_empresa_id int,
    cliente_empresa_razon_social varchar(100),
    cliente_empresa_nombre_comercial varchar(100),
    cliente_empresa_giro_negocio varchar(100),
    cliente_tipo_empresa varchar(100),

    persona_id int,
    cliente_nombre varchar(100),
    cliente_email varchar(100),
    cliente_fecha_nacimiento Date,
    cliente_sexo varchar(100),
    cliente_edad varchar(100),
    cliente_tipo_vivienda varchar(100),
    cliente_estado_civil varchar(100),
    cliente_tipo_ingreso varchar(100),
    cliente_nivel_estudios varchar(100),
    cliente_sector_economico varchar(100),
    cliente_profesion varchar(100),
    cliente_ocupacion varchar(100),
    cliente_num_dependientes varchar(100),
    cliente_num_hijos varchar(100),
    cliente_num_anios_envivienda varchar(100),
    cliente_monto_devengado varchar(100),
    cliente_fecha_creacion Date, -- fecha en la que forma a ser parte de la cartera de clientes del banco
    agencia_id int,
    agencia_codigo varchar(200),
    agencia_nombre varchar(200),
    agencia_ubicacion varchar(200),
    agencia_departamento varchar(100),
    agencia_provincia varchar(100),
    agencia_distrito varchar(100),
    empleado_id int,
    empleado_renuncia varchar(200),
    empleado_promotor varchar(200)
);
GO
SET IDENTITY_INSERT dim_cliente off; 
GO
insert into dim_cliente select 
    Cliente.idCliente,
    t.idCuentaCredito,
-- cliente:
    (case when Cliente.esAval=0 then 'NO' else 'SI' end) as esAval,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=Cliente.idEstadoCliente) as estado_cliente,
    (select upper(denominacion) from TipoCliente where idTipoCliente=Cliente.idTipoCliente) as tipo_cliente,
-- empresa donde labora el cliente:
    (select idEmpresa from PersonaEmpresa where idPersona = Persona.idPersona) as idEmpresa,
    (select upper(eMail) from Empresa where idEmpresa = (select idEmpresa from PersonaEmpresa where idPersona = Persona.idPersona)) as e_mail,
    (select nroRUC from Empresa where idEmpresa = (select idEmpresa from PersonaEmpresa where idPersona = Persona.idPersona)) as ruc,
    (select upper(razonSocial) from Empresa where idEmpresa = (select idEmpresa from PersonaEmpresa where idPersona = Persona.idPersona)) as razon_social,
    (select upper(nombreComercial) from Empresa where idEmpresa = (select idEmpresa from PersonaEmpresa where idPersona = Persona.idPersona)) as nombre_comercial,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=(select idTipoEmpresa from Empresa where idEmpresa = (select idEmpresa from PersonaEmpresa where idPersona = Persona.idPersona))) as tipo_empresa,
    (select upper(giroNegocio) from Empresa where idEmpresa = (select idEmpresa from PersonaEmpresa where idPersona = Persona.idPersona)) as giro,
    (select upper(cargoLaboral) from DetallePersona where idPersona = Persona.idPersona) as cargoLaboral,
-- empresa:
    (select idEmpresa from Empresa where idCliente=Cliente.idCliente) as cliente_empresa_id,
    (select upper(razonSocial) from Empresa where idCliente=Cliente.idCliente) as cliente_empresa_razon_social,
    (select upper(nombreComercial) from Empresa where idCliente=Cliente.idCliente) as cliente_empresa_nombre_comercial,
    (select upper(giroNegocio) from Empresa where idCliente=Cliente.idCliente) as cliente_empresa_giro_negocio,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=(
        select idTipoEmpresa from Empresa where idCliente = Cliente.idCliente)) as tipo_empresa,

-- persona:
    Persona.idPersona,
    upper(concat(Persona.nombres,', ',Persona.apePaterno,' ', Persona.apeMaterno)) as cliente_nombre, 
    upper(Persona.eMail),
    Persona.fechaNacimiento as fecha_nacimiento,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=Persona.idSexo) as sexo,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=Persona.idEstadoEdad) as estado_edad,
-- persona detalles:
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=(select idTipoVivienda from DetallePersona where idPersona = Persona.idPersona)) as tipo_vivienda,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=(select idEstadoCivil from DetallePersona where idPersona = Persona.idPersona)) as estado_civil,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=(select idTipoIngreso from DetallePersona where idPersona = Persona.idPersona)) as tipo_ingreso,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=(select idNivelEstudios from DetallePersona where idPersona = Persona.idPersona)) as nivel_estudios,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=(select idSectorEconomico from DetallePersona where idPersona = Persona.idPersona)) as sector_economico,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=(select idProfesion from DetallePersona where idPersona = Persona.idPersona)) as profesion,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=(select idOcupacion from DetallePersona where idPersona = Persona.idPersona)) as ocupacion,
    (select numDependientes from DetallePersona where idPersona = Persona.idPersona) as  numDependientes, 
    (select numHijos from DetallePersona where idPersona = Persona.idPersona) as numHijos ,
    (select numAniosEnVivienda from DetallePersona where idPersona = Persona.idPersona) as numAniosEnVivienda ,
    (select montoDevengado from DetallePersona where idPersona = Persona.idPersona) as montoDevengado ,
    (select fechaCreacion from DetallePersona where idPersona = Persona.idPersona) as fechaCreacion ,
-- asesores comerciales:
    Cliente.idAgenciaAfiliacion,
    (select codAgencia from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) codAgencia,
    (select upper(nombreAgencia) from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) nombreAgencia,
    (select upper(ubicacion) from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) ubicacion,
    (select upper(denominacion) from Ubigeo where codDpto=(select codDpto from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) and codProv='00' and codDist='00') as departamento,
    (select upper(denominacion) from Ubigeo where codDpto=(select codDpto from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) and codProv=(select codProv from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) and codDist='00') as provincia,
    (select upper(denominacion) from Ubigeo where codDpto=(select codDpto from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) and codProv=(select codProv from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) and codDist=(select codDist from Agencia where idAgencia=Cliente.idAgenciaAfiliacion)) as distrito,
    (select idUsuario from Empleado where idEmpleado = Cliente.idPromotor) as empleado_id,
    (case when Cliente.renuncia=0 then 'NO' else 'SI' end) empleado_renuncio,
    (select upper(concat(nombres,', ',apPaterno,' ', apMaterno)) from Empleado where idEmpleado = Cliente.idPromotor) empleado_promotor    
from Cliente
left join Persona on (Persona.idCliente=Cliente.idCliente)
inner join (
    select 
    ProductoSocio.idCliente, CuentaCredito.idCuentaCredito 
    from CuentaCredito 
    inner join ProductoSocio on (CuentaCredito.idProductoSocio= ProductoSocio.idProductoSocio)
) t on (Cliente.idCliente=t.idCliente)
where Persona.estado=1 and Cliente.estado=1;
GO
update dim_cliente set cliente_sexo ='MASCULINO' WHERE cliente_sexo is null;
-- cliente_empresa: solamente clientes que son empresas (p. jurídica) y que tienen cuenta credito
create table dim_cliente_empresa(
    dim_cliente_empresa_id int identity(1,1) primary key,
    empresa_id int,
    cliente_empresa_email varchar(200),
    cliente_empresa_ruc varchar(200),
    cliente_empresa_razon_social varchar(200),
    cliente_empresa_nombre_comercial varchar(200),
    cliente_empresa_tipo varchar(200),
    cliente_empresa_giro_negocio varchar(200),
    cliente_id int,
    cliente_aval varchar(200),
    cliente_estado varchar(200),
    cliente_tipo varchar(200), 
    agencia_id int,
    agencia_codigo varchar(200),
    agencia_nombre varchar(200),
    agencia_ubicacion varchar(200),
    agencia_departamento varchar(100),
    agencia_provincia varchar(100),
    agencia_distrito varchar(100),
    empleado_id int,
    empleado_renuncio varchar(200),
    empleado_promotor varchar(200)
);
GO
SET IDENTITY_INSERT dim_cliente_empresa off; 
GO
insert into dim_cliente_empresa SELECT 
-- empresa:
    Empresa.idEmpresa,
    upper(Empresa.eMail),
    Empresa.nroRUC,
    upper(Empresa.razonSocial),
    upper(Empresa.nombreComercial),
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=Empresa.idTipoEmpresa) tipo_empresa,
    upper(giroNegocio),
-- cliente:
    Cliente.idCliente,
    (case when Cliente.esAval=0 then 'NO' else 'SI' end) as esAval,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=Cliente.idEstadoCliente) as estado_cliente,
    (select upper(denominacion) from TipoCliente where idTipoCliente=Cliente.idTipoCliente) as tipo_cliente,
-- agencia:
    Cliente.idAgenciaAfiliacion,
    (select codAgencia from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) codAgencia,
    (select upper(nombreAgencia) from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) nombreAgencia,
    (select upper(ubicacion) from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) ubicacion,
    (select upper(denominacion) from Ubigeo where codDpto=(select codDpto from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) and codProv='00' and codDist='00') as departamento,
    (select upper(denominacion) from Ubigeo where codDpto=(select codDpto from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) and codProv=(select codProv from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) and codDist='00') as provincia,
    (select upper(denominacion) from Ubigeo where codDpto=(select codDpto from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) and codProv=(select codProv from Agencia where idAgencia=Cliente.idAgenciaAfiliacion) and codDist=(select codDist from Agencia where idAgencia=Cliente.idAgenciaAfiliacion)) as distrito,    
-- asesores comerciales:
    (select idUsuario from Empleado where idEmpleado = Cliente.idPromotor) as empleado_id,
    (case when Cliente.renuncia=0 then 'NO' else 'SI' end) empleado_renuncio,
    (select upper(concat(nombres,', ',apPaterno,' ', apMaterno)) from Empleado where idEmpleado = Cliente.idPromotor) empleado_promotor
from Empresa inner join Cliente on (Cliente.idCliente=Empresa.idCliente)
inner join (
select 
    distinct ProductoSocio.idCliente
    from CuentaCredito 
    inner join ProductoSocio on (CuentaCredito.idProductoSocio= ProductoSocio.idProductoSocio)
) t on (t.idCliente = Cliente.idCliente and t.idCliente = Empresa.idCliente)
where Cliente.estado=1;
GO
select * from dim_cliente_empresa;



-- //////////////////////////////////////////////////////

-- producto_credito

create table dim_producto_credito(
    dim_producto_credito_id int identity(1,1) primary key,
    cuenta_id int,
    cuenta_producto varchar(200),
    cuenta_tipo_producto varchar(200),
    cuenta_tipo_credito varchar(200),
    cuenta_moneda varchar(200),
    cuenta_fecha_desembolso Date,
    cuenta_fecha_ini_pago Date,
    cuenta_fecha_fin_pago Date,
    cuenta_fecha_fin_real Date,
    cuenta_tipo_calculo_cuota varchar(200),
    cuenta_modalidad_pago varchar(200),
    cuenta_dia_pago varchar(200),
    cuenta_nro_cuotas int,
    cuenta_periodo int,
    cuenta_encaje decimal(12,4),
    cuenta_monto_desembolso decimal(12,4),
    cuenta_capital decimal(12,4),
    cuenta_monto_total decimal(12,4),
    cuenta_monto_actual decimal(12,4),
    cuenta_interes decimal(12,4),
    cuenta_tea decimal(12,4),
    cuenta_tem decimal(12,4),
    cuenta_ted decimal(12,4),
    cuenta_tea_mora decimal(12,4),
    cuenta_tem_mora decimal(12,4),
    cuenta_ted_mora decimal(12,4),
    cuenta_cuota_simple varchar(200),
    cuenta_cuota_doble varchar(200),
    cuenta_tiene_cuota_doble varchar(200),
    cuenta_es_pronto_pago varchar(200),
    cuenta_periodo_gracia varchar(200),
    cuenta_interes_periodo_gracia varchar(200),
    cuenta_capital_condonado decimal(12,4),
    cuenta_interes_condonado decimal(12,4),
    cliente_id int,
    cliente_empresa_id int,
    cliente_aval varchar(200),
    cliente_estado varchar(200),
    cliente_tipo varchar(200),
    agencia_id int,
    agencia_codigo varchar(200),
    agencia_nombre varchar(200),
    agencia_ubicacion varchar(200),
    agencia_departamento varchar(200),
    agencia_provincia varchar(200),
    agencia_distrito varchar(200),
    empleado_id int,
    empleado_analita_id int,
    empleado_promotor varchar(200),
    empleado_analista varchar(200)
);
GO
SET IDENTITY_INSERT dim_producto_credito off; 
GO
insert into dim_producto_credito select 
-- CuentaCredito y ProductoSocio:
    CuentaCredito.idCuentaCredito,
    upper(ProductoSocio.tituloProducto),
    (select upper(denominacion) from TipoProducto where idTipoProducto=ProductoSocio.idTipoProducto) as tipo_producto,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=CuentaCredito.idTipoCredito) as tipo_credito,
    (select upper(denominacion) from Moneda where idMoneda=CuentaCredito.idMoneda) as moneda,
    CuentaCredito.fechaDesembolso, 
    CuentaCredito.fechaIniPago,
    CuentaCredito.fechaFinPago,
    CuentaCredito.fechaFinReal,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=CuentaCredito.idTipoCalculoCuota) as tipo_calculo_cuota,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=CuentaCredito.idModalidadPago) as modalidad_pago,
    upper(CuentaCredito.diaPago),
    CuentaCredito.nroCuotas,
    CuentaCredito.periodo,
    CuentaCredito.encaje,
    CuentaCredito.montoDesembolso,
    CuentaCredito.capital,
    CuentaCredito.montoTotal,
    ProductoSocio.montoActual,
    CuentaCredito.interes,
    CuentaCredito.tea,
    CuentaCredito.tem,
    CuentaCredito.ted,
    CuentaCredito.teaMora,
    CuentaCredito.temMora,
    CuentaCredito.tedMora,
    CuentaCredito.cuotaSimple,
    CuentaCredito.cuotaDoble,
    CuentaCredito.tieneCuotaDoble, 
    CuentaCredito.esProntoPago,
    CuentaCredito.periodoGracia,
    CuentaCredito.interesPeriodoGracia,
    CuentaCredito.capitalCondonado,
    CuentaCredito.interesCondonado, 
-- cliente:
    Cliente.idCliente,
    (select idEmpresa from Empresa where idCliente=Cliente.idCliente),
    (case when Cliente.esAval=0 then 'NO' else 'SI' end) as esAval,
    (select upper(denominacion) from TablaMaestra where idTablaMaestra=Cliente.idEstadoCliente) as estado_cliente,
    (select upper(denominacion) from TipoCliente where idTipoCliente=Cliente.idTipoCliente) as tipo_cliente,
-- agencia: 
    CuentaCredito.idAgencia,
    (select codAgencia from Agencia where idAgencia=CuentaCredito.idAgencia) codAgencia,
    (select upper(nombreAgencia) from Agencia where idAgencia=CuentaCredito.idAgencia) nombreAgencia,
    (select upper(ubicacion) from Agencia where idAgencia=CuentaCredito.idAgencia) ubicacion,
    (select upper(denominacion) from Ubigeo where codDpto=(select codDpto from Agencia where idAgencia=CuentaCredito.idAgencia) and codProv='00' and codDist='00') as departamento,
    (select upper(denominacion) from Ubigeo where codDpto=(select codDpto from Agencia where idAgencia=CuentaCredito.idAgencia) and codProv=(select codProv from Agencia where idAgencia=CuentaCredito.idAgencia) and codDist='00') as provincia,
    (select upper(denominacion) from Ubigeo where codDpto=(select codDpto from Agencia where idAgencia=CuentaCredito.idAgencia) and codProv=(select codProv from Agencia where idAgencia=CuentaCredito.idAgencia) and codDist=(select codDist from Agencia where idAgencia=CuentaCredito.idAgencia)) as distrito,    
-- asesores:
    CuentaCredito.idUsuarioPromotor,
    CuentaCredito.idUsuarioAnalista,
    (select upper(concat(nombres,', ',apPaterno,' ', apMaterno)) from Empleado where idUsuario = CuentaCredito.idUsuarioPromotor) empleado_promotor,
    (select upper(concat(nombres,', ',apPaterno,' ', apMaterno)) from Empleado where idUsuario = CuentaCredito.idUsuarioAnalista) empleado_analista
from CuentaCredito 
inner join ProductoCredito on (ProductoCredito.idProductoCredito=CuentaCredito.idProductoCredito)
inner join ProductoSocio on (ProductoSocio.idProductoSocio=CuentaCredito.idProductoSocio)
inner join Cliente on (Cliente.idCliente=ProductoSocio.idCliente) 
where Cliente.estado=1;
GO
select * from dim_producto_credito;




-- //////////////////////////////////////////////////////

-- drop table dim_tiempo
create table dim_tiempo(
    dim_tiempo_id int identity(1,1) primary key,
    cuenta_id int,
    fecha varchar(20),
    anio varchar(20),
    mes varchar(20),
    dia varchar(20)
);
GO
SET IDENTITY_INSERT dim_tiempo off; 
GO
insert into dim_tiempo select 
cuenta_id,
cuenta_fecha_desembolso,
year(cuenta_fecha_desembolso), 
month(cuenta_fecha_desembolso), 
day(cuenta_fecha_desembolso)
from dim_producto_credito;
GO
select * from dim_tiempo;

-- //////////////////////////////////////////////////////

-- drop table fact_credito_otorgado
create table fact_credito_otorgado(
    fact_credito_otorgado_id int identity(1,1) primary key,
    dim_agencia_id int FOREIGN KEY REFERENCES dim_agencia (dim_agencia_id),
    dim_empleado_id int FOREIGN KEY REFERENCES dim_empleado (dim_empleado_id),
    dim_tiempo_id int FOREIGN KEY REFERENCES dim_tiempo (dim_tiempo_id), -- fechas de desembolso
    dim_cliente_id int FOREIGN KEY REFERENCES dim_cliente (dim_cliente_id),
    dim_cliente_empresa_id int FOREIGN KEY REFERENCES dim_cliente_empresa (dim_cliente_empresa_id),
    dim_producto_credito_id int FOREIGN KEY REFERENCES dim_producto_credito (dim_producto_credito_id),
    empleado_agencia_id int FOREIGN KEY REFERENCES dim_agencia (dim_agencia_id), -- agencia en donde labora el empleado
    cliente_id int,
    cuenta_id int,
    cuenta_fecha_desembolso Date,
    cuenta_anio_desembolso varchar(4),
    cuenta_mes_desembolso varchar(2),
    cuenta_dia_desembolso varchar(2),
    cuenta_monto_desembolso varchar(100),
    cuenta_capital varchar(100),
    cuenta_monto_total varchar(100),
    cuenta_monto_actual varchar(100),
    cuenta_nro_cuotas varchar(100),
    cuenta_periodo varchar(100),
    cuenta_modalidad_pago varchar(100),
    cuenta_tea varchar(100),
    cuenta_tea_mora varchar(100)
);
GO
SET IDENTITY_INSERT fact_credito_otorgado off; 
GO

insert into fact_credito_otorgado(
    dim_producto_credito_id,
    dim_agencia_id,
    dim_cliente_id,
    dim_empleado_id,
    empleado_agencia_id,
    dim_tiempo_id, -- fechas de desembolso
    dim_cliente_empresa_id,
    cliente_id,
    cuenta_id,
    cuenta_fecha_desembolso,
    cuenta_anio_desembolso,
    cuenta_mes_desembolso,
    cuenta_dia_desembolso,
    cuenta_monto_desembolso,
    cuenta_capital,
    cuenta_monto_total,
    cuenta_monto_actual,
    cuenta_nro_cuotas,
    cuenta_periodo,
    cuenta_modalidad_pago,
    cuenta_tea,
    cuenta_tea_mora
) select 
    dim_producto_credito_id,
    (select dim_agencia_id from dim_agencia where agencia_id = dim_producto_credito.agencia_id) as dim_agencia_id,
    (select dim_cliente_id from dim_cliente where cliente_id=dim_producto_credito.cliente_id and cuenta_id=dim_producto_credito.cuenta_id) as dim_cliente_id,
    (select dim_empleado_id from dim_empleado where empleado_id = dim_producto_credito.empleado_id) as dim_empleado_id,
    (select dim_agencia_id from dim_agencia where dim_agencia_id = (select agencia_id from dim_empleado where empleado_id = dim_producto_credito.empleado_id)) as dim_agencia_id,
    (select dim_tiempo_id from dim_tiempo where cuenta_id = dim_producto_credito.cuenta_id) as dim_tiempo_id,
    (select dim_cliente_empresa_id from dim_cliente_empresa where cliente_id=dim_producto_credito.cliente_id) as dim_cliente_empresa_id,
    cliente_id,
    cuenta_id,
    cuenta_fecha_desembolso,
    year(cuenta_fecha_desembolso),
    month(cuenta_fecha_desembolso),
    day(cuenta_fecha_desembolso),
    cuenta_monto_desembolso,
    cuenta_capital,
    cuenta_monto_total,
    cuenta_monto_actual,
    cuenta_nro_cuotas,
    cuenta_periodo,
    cuenta_modalidad_pago,
    cuenta_tea,
    cuenta_tea_mora
from dim_producto_credito;




-- select * from fact_credito_otorgado;
-- select * from dim_agencia;
-- select * from dim_cliente;
-- select * from dim_cliente_empresa;
-- select * from dim_empleado;
-- select * from dim_producto_credito;
-- select * from dim_tiempo;


-- drop table fact_credito_otorgado;
-- drop table dim_agencia;
-- drop table dim_cliente;
-- drop table dim_cliente_empresa;
-- drop table dim_empleado;
-- drop table dim_producto_credito;
-- drop table dim_tiempo;
 