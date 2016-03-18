
import {BluetoothService} from "./bluetooth.service";

@Component({
	selector: 'bluetooth-button',
	template: `
		<button md-raised-button md-ink class="md-ink md-icon-button md-primary md-raised">
			<i class="material-icons">{{status}}</i>
		</button>
	`,
	providers: [BluetoothService]
})

export class BluetoothComponent {
	status: string = Status.waiting;
	constructor(public bluetoothService:BluetoothService){
		bluetoothService.connect((success) => {
			console.log(success);
			if(success) {
				this.status = Status.connected;
			}else{
				this.status = Status.waiting;
			}
		});
	}
}

class Status {
	static waiting = "bluetooth";
	static connected = "bluetooth_connected";
	static connecting = "bluetooth_searching";
}