Este contrato inteligente implementa un sistema de subastas descentralizado en la blockchain de Ethereum. Permite a los usuarios pujar por un ítem específico durante un período determinado, con reglas claras para garantizar la transparencia y seguridad del proceso.

Funcionamiento General
El contrato gestiona una subasta cronometrada donde los participantes envían ofertas en ETH. Cada nueva oferta debe ser al menos un 5% mayor que la anterior. El sistema registra automáticamente al mejor postor y mantiene un registro de los fondos reembolsables para los participantes que sean superados por ofertas mayores.

Cuando la subasta finaliza, el beneficiario (quien desplegó el contrato) puede reclamar los fondos de la oferta ganadora, con una comisión del 2% que se deduce automáticamente. Los participantes que no ganaron pueden retirar sus fondos en cualquier momento después de haber sido superados por otra oferta.

Características Clave
El contrato incluye mecanismos de protección importantes. Si alguien realiza una oferta válida durante los últimos 10 minutos de la subasta, el tiempo se extiende automáticamente por 10 minutos más. Esto previene el "sniping" (ofertas de último momento) y da a todos los participantes una oportunidad justa de responder.

Todas las transacciones de ETH se manejan con verificaciones de seguridad para prevenir pérdidas de fondos. El contrato utiliza el patrón Checks-Effects-Interactions para evitar vulnerabilidades de reentrada, y todas las transferencias incluyen comprobaciones para confirmar su éxito.

Eventos y Transparencia
El contrato emite eventos en la blockchain para cada acción importante: cuando se realiza una nueva oferta, cuando alguien retira fondos y cuando la subasta finaliza. Esto permite a los participantes y observadores rastrear la actividad de la subasta de forma transparente mediante exploradores de bloques como Etherscan.

Uso del Contrato
Los usuarios interactúan principalmente a través de tres funciones: puja() para hacer ofertas, retirar() para reclamar fondos de ofertas no ganadoras, y finalizar() (solo para el beneficiario) para concluir la subasta y recibir los fondos. El contrato también ofrece funciones de consulta para verificar el estado actual, el tiempo restante y los detalles del ítem en subasta.
