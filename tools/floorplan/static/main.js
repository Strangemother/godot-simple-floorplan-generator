var app = new Vue({
    el:'#app'

    , data: {
        items: [
            [0, 1, 0]
        ]
        , allowPaintReflip: false
        , count: 6
        , filename: 'friendly'
        , outString: 'Nothing'
    }
    , mounted(){
        this.buildRows()
    }

    , methods: {
        buildRows(){
            let rows = []
            for(var i=0; i<this.count; i++) {
                let row = []
                for (var j = 0; j <this.count; j++) {
                    row.push(Math.round(Math.random()))
                }
                rows.push(row)
            }
            Vue.set(this, 'items', rows)
        }
        , toggle_cell(event) {
            let target = event.target
            this.last = event.target
            console.log('click.', target)
            let ri = target.getAttribute('rowindex')
            let ci = target.getAttribute('cellindex')
            if(ri == null) {
                target = event.target.parentNode
                ri = target.getAttribute('rowindex')
                ci = target.getAttribute('cellindex')
            }
            let val = this.items[ri][ci]
            let valFlip = +!Boolean(Number.parseInt(val));
            this.items[ri][ci] = valFlip
            app.$forceUpdate()
        }

        , updateSize(e){
            e.preventDefault()
            Vue.set(this, 'count', Number(this.$refs.size.value))
            this.buildRows()
            return false
        }

        , mousedown(){
            this.enablePainter()
            console.log('Mouse down')
        }

        , mouseup(){
            this.disablePainter()
            console.log('Mouse Up')

            if(this.upTimer) {
                clearTimeout(this.upTimer)
            }
            this.upTimer = setTimeout(function() {
                if(this.painting == false) {
                    console.log('delete paints')
                    this.$refs.cell.forEach(e => e.classList.remove('painting'))
                    app.$forceUpdate()

                }
            }.bind(this), 1000)
        }

        , mousemove(event){
            if(this.painting) {
                let target = event.target
                if(this.last == target) {
                    // slow move; do nothing.
                    return
                }

                let ri = target.getAttribute('rowindex')
                let ci = target.getAttribute('cellindex')
                if(ri == null) {
                    return
                }

                if(target.classList.contains('painting') ) {
                    // ignore done.
                    if(this.allowPaintReflip == false) {
                        return
                    }
                    //return
                }

                //console.log(target)
                let val = this.items[ri][ci]
                let valFlip = +!Boolean(Number.parseInt(val));
                this.items[ri][ci] = valFlip
                let func = ['remove', 'add'][valFlip]
                target.classList['add']('painting')
                this.last = event.target
                //app.$forceUpdate()
            }
        }

        , enablePainter(){
            this.painting = true
        }

        , disablePainter(){
            this.painting = false
        }

        , storeString(){
            return JSON.stringify({items:app.items, count: app.count})
        }

        , sendSave(e){
            e.preventDefault()
            console.log('send')
            this.postDirty({
                name: this.filename
                , count: this.count
                , items: this.contentString()
            })
        }

        , save(){
            localStorage['floorplan'] = this.storeString()
            return 'floorplan' in localStorage
        }

        , restore(){
            let data = JSON.parse(localStorage['floorplan'])
            Vue.set(this, 'items', data.items)
            Vue.set(this, 'count', data.count)
            this.$forceUpdate()
        }

        , postDirty(opts) {

            fetch('/dirty/post/', {
                method: 'post',
                body: JSON.stringify(opts)
            }).then(function(response) {
                return response.json();
            }).then(function(data) {

            });
        }

        , contentString(){
            let r = []
            for (var i = 0; i < this.items.length; i++) {

                r = r.concat(this.items[i])
            }
            return r
        }

        , invert(){
            let r = [], items = this.items

            for (var i = 0; i < items.length; i++) {
                let _r = []
                let row = items[i]
                for (var j = 0; j < row.length; j++) {
                    _r.push(row[j] ^ 1)
                }
                r.push(_r)
            }
            Vue.set(this, 'items', r)
        }
    }
})
