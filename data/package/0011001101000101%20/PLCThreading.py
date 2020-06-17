from Mc_protocol import *
from PyQt5.QtCore import *
from Logging import *
import DataRead

####################### Class Threading #######################


class MelsecWorker(QObject):
    # ----------------------- Property -----------------------

    StateMachine = pyqtSignal(int)
    InputQuantity = pyqtSignal(int)
    OutputQuantity = pyqtSignal(int)
    PLCComunication = pyqtSignal(int)
    TrigReset = pyqtSignal()
    finished = pyqtSignal()

    # ----------------------- Variable ------------------------

    StateMC = []
    StateComunication = 0
    InputConvert = 0
    OutputConvert = 0
    Reset = False

    def __init__(self):
        super(MelsecWorker, self).__init__()
        self.existing = True
        self.logging = Logging()
        self.Parameter = DataRead.readParameter()
        self.TrigReset.connect(self.SetTrigReset)

    def PLCWorker(self):
        """
            Threading run OPEN PORT MCPROTOCOL OF MITSUBISHI
        """
        Device = mcProtocol(self.Parameter[2], int(
            self.Parameter[3]), "TCP",
            msgSize=1024, Debug=False)

        while True:
            try:
                self.StateMC = Device.readBit("M", 100, 1)
                if len(self.StateMC) > 0:
                    if self.StateMC[0] == 0:
                        self.StateMachine.emit(0)
                    elif self.StateMC[0] == 1:
                        self.StateMachine.emit(1)
                    else:
                        pass
                Input = Device.readWord("D", 102, 2)
                Output = Device.readWord("D", 100, 2)
                time.sleep(1)

                # Triger Coil for reset Device
                if self.Reset == True:
                    Device.writeBit('M', 170, 'SET')
                    time.sleep(0.5)
                    Device.writeBit('M', 170, 'RESET')
                    self.Reset = False

                # Convert
                self.InputConvert = Device.read32bit(Input[0], Input[1])
                if not self.InputConvert is None:
                    self.InputQuantity.emit(self.InputConvert)
                self.OutputConvert = Device.read32bit(Output[0], Output[1])
                if not self.OutputConvert is None:
                    self.OutputQuantity.emit(self.OutputConvert)
                self.StateComunication = 1
            except Exception as err:
                self.logging.DebugLoggging("PLC ERROR COM".format(err), 2)
                self.StateComunication = 0
                print("Error PLC Threading : {}".format(err))
                pass
            # ---------------- Emit Data to Main Threading ----------------#
            if not self.StateComunication is None:
                self.PLCComunication.emit(self.StateComunication)
        Device.closeConnect()
        # self.finished.emit()

    def PLCStop(self):
        self.existing = False

    def SetTrigReset(self):
        self.Reset = True
