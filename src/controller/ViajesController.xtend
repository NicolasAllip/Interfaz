package controller

import org.uqbar.commons.applicationContext.ApplicationContext
import org.uqbar.commons.model.exceptions.UserException
import org.uqbar.xtrest.api.Result
import org.uqbar.xtrest.api.XTRest
import org.uqbar.xtrest.api.annotation.Body
import org.uqbar.xtrest.api.annotation.Controller
import org.uqbar.xtrest.api.annotation.Get
import org.uqbar.xtrest.api.annotation.Post
import org.uqbar.xtrest.api.annotation.Put
import org.uqbar.xtrest.json.JSONUtils
import repos.RepoClientes
import repos.RepoPasajes
import repos.RepoUsuarios
import repos.RepoViajes
import viaje.Cliente
import viaje.Pasaje
import viaje.Usuario
import viaje.Viaje

@Controller
class ViajesController {
	extension JSONUtils = new JSONUtils
	

	val repoUsuarios = RepoUsuarios.instance
	val repoClientes = RepoClientes.instance
	val repoViajes = RepoViajes.instance
	val repoPasajes = RepoPasajes.instance
	
	
// Devuelve todos los viajes
	@Get("/viajes")
	def viajes() {
		ok(repoViajes.allInstances.toJson)
	}
	
// Devuelve todos los usuarios
	@Get("/usuarios")
	def usuarios() {
		ok(repoUsuarios.allInstances.toJson)
	}
	
// Devuelve todos los pasajes
	@Get("/pasajes")
	def pasajes() {

		ok(repoPasajes.pasajes.toJson)
	}
	
// Devuelve todos los clientes
	@Get("/clientes")
	def clientes() {
		ok(repoClientes.allInstances.toJson)
	}

// Crea un usuario
	@Post("/usuarios")
	def Result createUser(@Body String body) {
		try {
			if (body === null || body.trim.equals("")) {
				return badRequest("Faltan datos usuario")
			}			
			val nuevoUser = body.fromJson(Usuario)
			nuevoUser.validar 
			repoUsuarios.validarUsuariosDuplicados(nuevoUser) 
			
			repoClientes.create(nuevoUser.cliente)
			repoUsuarios.create(nuevoUser)	
			
			ok(repoUsuarios.searchUser(nuevoUser.username,nuevoUser.password).toJson)
		} catch (UserException e) {
			badRequest(getErrorJson(e.message))
		}
	}
	
	private def String getErrorJson(String message) {
        '''{ "error" : "«message»" }'''
    }

// Modifica al cliente que esta asociado a un usuario
// Validar porque no termina de manera exitosa cuando busca por ID, a demas corregir el update( Entiendo que deberia unicamente pisar los valores modificados, no eliminar la instancia del objeto y volverlo a crear)
	@Put("/usuarios/:username")
	def Result modificarUsuario(@Body String body){
		try {
		
		println(body)
		val user = body.fromJson(Usuario)
		repoClientes.update(user.cliente)
		
		ok(repoUsuarios.searchById(user.id).toJson)
		} catch (UserException e) {
			badRequest(getErrorJson(e.message))
		}
	}

// Login de usuario
	@Post("/login")
	def Result login(@Body String body){
		try {
		val nuevoUser = body.fromJson(Usuario)
		
		ok(repoUsuarios.searchUser(nuevoUser.username,nuevoUser.password).toJson)
		} catch (UserException e) {
			badRequest(getErrorJson(e.message))
		}
	}
	
//Búsqueda de Viajes
//Devuelve una lista de viajes según los criterios recibidos en la URL: ciudadPartida, ciudadLlegada, fechaPartida, fechaLlegada. Los 4 son opcionales.

	@Get("/viajes/search")
	def Result viajesFiltrados(String ciudadPartida,String ciudadLlegada,String fechaPartida,String fechaLlegada){
		
		ok('''"«repoViajes.search(ciudadPartida,ciudadLlegada,fechaPartida,fechaLlegada).toJson»"''')
	}

//Compra de Pasaje
//Carga un pasaje nuevo al cliente asociado al usuario. Por el momento, los datos del pago serán ignorados en la implementación.
// Primero validar el usuario, luego validar la disponibilidad del asiento del pasaje en el caso que este ok 

	@Post("/pasajes")
	def Result crearPasaje(@Body String body){
	try {
			if (body === null || body.trim.equals("")) {
				return badRequest("Faltan datos del pasaje")
			}
			
			var nuevoPasaje = body.fromJson(Pasaje)
			nuevoPasaje.validar
			var cliente = repoUsuarios.searchUser(nuevoPasaje.username,nuevoPasaje.password).cliente
			var viaje = repoViajes.searchById(nuevoPasaje.viajeId)
			cliente.comprarPasaje(viaje,nuevoPasaje.numeroDeAsiento)
			
			ok('''{ "status" : "ok" }''')
			
		} catch (UserException e) {
			badRequest(getErrorJson(e.message))
		}
	}

//Cancelar un pasaje comprado

	@Post("/pasajes/:id/cancelar")
	def Result cancelarPasaje(){
		
		repoPasajes.cancelarPasaje(Integer.valueOf(id))
		
		ok('''{ "status" : "ok, se cancelo el pasaje con el id: " "«id» " }''')	
	}
	
	def static void main(String[] args) {
		XTRest.start(9400, ViajesController)
	}
}
