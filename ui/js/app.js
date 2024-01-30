function main() {
    return {
        show: false,
        
        listen() {
            window.addEventListener('message', (event) => {
                let data = event.data

                switch(data.type) {
                    case 'show':
                        this.show = data.show;
                        break;
                }
            })
        }
    }
}
