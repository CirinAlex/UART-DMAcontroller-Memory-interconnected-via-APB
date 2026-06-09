# APB Interface
ARM AMBA APB version E interface implementation. Consist of a requester and completer modules. Both modules are modelled in a scalable method.\


[Click here](https://developer.arm.com/documentation/ihi0024/latest/amba-apb-protocol-version-20-specification) to download official documentation of APB version E from ARM

# Implemented Features
- Utilized PSLVERR (defined in the documentation Section 3.4) to signal error for invalid memory address and invalid (restricted) read or write.
- Supports transfers WITH and WITHOUT WAIT STATES.
  - the transfer will occur without wait state when ready of interface is pulled high all the time.


