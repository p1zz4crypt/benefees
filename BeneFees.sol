// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7 <0.9.0;

contract Voting {

    // Totalidad de votos
    uint256 totalVotos = 0;

    //Propietario
    address propietario; 

    //id de cada candidato que sera creado.
    uint nextId = 1;

    /* ------------------------------ Validacion del Propietario  ------------------------------*/
        // _;  Primero se va a ejecutar el (require) despues de la funcion validarPropietario
        modifier validarPropietario(){
            require(msg.sender == propietario, "Tu no eres el Propietario !");
            _;
        }
        // Se asigna el valor del propietario a la variable .
        constructor(){
            propietario = msg.sender;
        }
    
    /* ------------------------------ Validacion del Votante ------------------------------*/

        //Estructura del votante
        struct votante{
            uint256 identificacion;
            string nombre;
            uint edad;
            bool yaVoto;
            bool puedeVotar;
        }

        //Almacenamiento de informacion (clave , valor)
        // mapping(address => votante[]) votantes;
        mapping(address => votante[]) public votantes;
        // Request[] private requests;

        //Registramos al votante
        function registroVotante(string memory _nombre, uint _edad) public{
            votantes[msg.sender].push(votante(nextId, _nombre, _edad, false, false));
            nextId++;
        }

        //funcion para buscar el indice del votante
        function findIndex(uint _id) internal view returns(uint){
            for(uint i = 0; i < votantes[msg.sender].length; i++){
                if(votantes[msg.sender][i].identificacion == _id){
                    return i;
                }
            }
            //si no encuentra la identificacion
            revert("Votante no encontrado!");
        }
        
        //funcion para obtener solo un votante string memory es para indicar que los valores son guardados temporalmente
        function leerVotante(uint _id) public view returns (uint, string memory, uint, bool, bool){
            //llama al index y lo guarda en una variable
            uint index = findIndex(_id);
            //retornar el valor de la tarea, se debe retirnar uno a uno los valores
            return (votantes[msg.sender][index].identificacion, 
                    votantes[msg.sender][index].nombre,
                    votantes[msg.sender][index].edad, 
                    votantes[msg.sender][index].yaVoto, 
                    votantes[msg.sender][index].puedeVotar);
        }

    /* ------------------------------ Validacion de la propuesta ------------------------------*/
        //Propuestas
        struct propuesta{
            uint id;
            bytes32 name;   // nombre corto (hasta 32 bytes)
            uint256 votos; // Votos acumulados
        }
        //Se definen Propuestas
        propuesta  propuestaUno= propuesta({
            id:1,
            name: 'Hospital para Mascotas',
            votos: 0
        });
        propuesta  propuestaDos= propuesta({
            id:2,
            name: 'Cuidado del medio ambiente',
            votos: 0
        });

        propuesta[] public propuestas;
    
        //Otorgar derecho a votar - Valida primero si ya ha votado o de lo contrario se le concede derecho 
        function validarDerechoVotar (address _votante) public validarPropietario {
            for (uint v = 0; v < votantes[msg.sender].length; v++) { 
                require (!votantes[msg.sender][v].puedeVotar, "Ya tienes derecho a votar");
                votantes[_votante][v].puedeVotar = true;
            }
        }

        function votar(uint256 _ipropuesta) public {
            for (uint m = 0; m < votantes[msg.sender].length; m++) {
                require (votantes[msg.sender][m].puedeVotar, "No tienes derecho a Votar");
                require (!votantes[msg.sender][m].yaVoto, "Ya votaste, no puedes volver a hacerlo");

                votantes[msg.sender][m].yaVoto = true;
                totalVotos += 1;                
            }

            if( propuestaUno.id == _ipropuesta){
                propuestaUno.votos += 1;
            }else{
                propuestaDos.votos +=1;
            }
        }

        /** 
        * @dev Calcular la propuesta ganadora.
        * @return propuestaGanadora_ Indice de la proposición ganadora
        */
        function propuestaGanadora() view public returns (uint propuestaGanadora_){
            uint conteoPropuestaGanadora = 0;
            for (uint p = 0; p < propuestas.length; p++) { 
                    if (propuestas[p].votos > conteoPropuestaGanadora) {
                        conteoPropuestaGanadora = propuestas[p].votos;
                        propuestaGanadora_ = p;
                    }
            }
        }

        /** 
        * @dev Invoca winningProposal() que recupeera el indice de la propuesta ganadora
        * @return winnerName_ el nombre deel ganador
        */
        function nombrePropuestaGanadora() public view returns (bytes32 winnerName_) {
            winnerName_ = propuestas[propuestaGanadora()].name;
        }

}