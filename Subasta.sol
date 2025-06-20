// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Auction {
    // Estructura para el ítem de la subasta
    struct Item {
        string nombre;
        string descripcion;
    }

    // Eventos
    event NuevaOferta(address indexed oferente, uint256 cantidad);
    event SubastaFinalizada(address indexed ganador, uint256 cantidad);
    event ReembolsoExitoso(address indexed oferente, uint256 cantidad);

    // Errores personalizados
    error Auction__BidderMasAltoNoSePuedeRetirar();
    error Auction__NoHayPujasPendientes();
    error Auction__NoSePudoCompletarElServicio();
    error Auction__SubastaNoHaFinalizado();
    error Auction__OfertaInsuficiente();
    error Auction__SubastaYaFinalizada();
    error Auction__SoloBeneficiarioPuedeFinalizar();

    // Variables de estado
    address payable public immutable beneficiario;
    address public bidderMasAlto;
    uint256 public bidMasAlto;
    uint256 public endTime;
    bool public finalizada;
    uint256 public constant COMISION = 2; // 2%
    uint256 public constant MIN_EXTENSION = 10 minutes;
    uint256 public constant MIN_INCREMENTO = 5; // 5%
    
    mapping(address => uint256) public pujasPendientes;
    Item public item;

    // Modificador para verificar si la subasta está activa
    modifier soloActiva() {
        require(block.timestamp < endTime, "Subasta ha finalizado");
        require(!finalizada, "Subasta ya finalizada");
        _;
    }

    // Modificador para verificar si la subasta ha finalizado
    modifier soloFinalizada() {
        require(block.timestamp >= endTime || finalizada, "Subasta no ha finalizado");
        _;
    }

    constructor(address _beneficiario, string memory _nombre, string memory _descripcion) {
        beneficiario = payable(_beneficiario);
        item = Item({
            nombre: _nombre,
            descripcion: _descripcion
        });
        endTime = block.timestamp + 1 days; // Subasta de 1 día por defecto
    }

    // Función para realizar una puja
    function puja() external payable soloActiva {
        // Calcular el mínimo incremento requerido (5%)
        uint256 minimoRequerido = bidMasAlto + (bidMasAlto * MIN_INCREMENTO) / 100;
        
        // Para la primera oferta, solo necesita ser mayor que 0
        if (bidMasAlto > 0) {
            require(msg.value >= minimoRequerido, "La oferta debe ser al menos 5% mayor");
        } else {
            require(msg.value > 0, "La oferta debe ser mayor que 0");
        }

        // Si hay un oferente anterior, registrar su oferta pendiente
        if (bidderMasAlto != address(0)) {
            pujasPendientes[bidderMasAlto] += bidMasAlto;
        }

        // Actualizar el oferente más alto y su oferta
        bidderMasAlto = msg.sender;
        bidMasAlto = msg.value;

        // Extender la subasta si queda menos de 10 minutos
        if (endTime - block.timestamp < 10 minutes) {
            endTime = block.timestamp + MIN_EXTENSION;
        }

        emit NuevaOferta(msg.sender, msg.value);
    }

    // Función para retirar fondos pendientes
    function retirar() external {
        if (msg.sender == bidderMasAlto && !finalizada) {
            revert Auction__BidderMasAltoNoSePuedeRetirar();
        }

        if (pujasPendientes[msg.sender] == 0) {
            revert Auction__NoHayPujasPendientes();
        }

        uint256 amountToSend = pujasPendientes[msg.sender];
        pujasPendientes[msg.sender] = 0;

        (bool sent, ) = payable(msg.sender).call{value: amountToSend}("");
        if (!sent) {
            revert Auction__NoSePudoCompletarElServicio();
        }

        emit ReembolsoExitoso(msg.sender, amountToSend);
    }

    // Función para finalizar la subasta (solo el beneficiario puede llamarla)
    function finalizar() external soloFinalizada {
        if (msg.sender != beneficiario) {
            revert Auction__SoloBeneficiarioPuedeFinalizar();
        }
        
        if (finalizada) {
            revert Auction__SubastaYaFinalizada();
        }

        finalizada = true;

        // Calcular comisión del 2%
        uint256 comision = (bidMasAlto * COMISION) / 100;
        uint256 cantidadBeneficiario = bidMasAlto - comision;

        // Transferir al beneficiario (con comisión del 2%)
        (bool sent, ) = beneficiario.call{value: cantidadBeneficiario}("");
        require(sent, "Fallo al transferir al beneficiario");

        emit SubastaFinalizada(bidderMasAlto, bidMasAlto);
    }

    // Función para obtener detalles del ítem
    function getItem() external view returns (string memory, string memory) {
        return (item.nombre, item.descripcion);
    }

    // Función para obtener el tiempo restante
    function getTiempoRestante() external view returns (uint256) {
        if (block.timestamp >= endTime) {
            return 0;
        }
        return endTime - block.timestamp;
    }

    // Función para obtener el estado de la subasta
    function getEstadoSubasta() external view returns (bool) {
        return !finalizada && block.timestamp < endTime;
    }
}