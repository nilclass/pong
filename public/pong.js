
var game;

var KEY_UP = 38;
var KEY_DOWN = 40;

(function($) {

    var Pong = function(socket) {
        this.socket = socket;
        this.canvas = $('#playground');
        this.canvas[0].height = this.height;
        this.canvas[0].width = this.width;

        this.keyCommands[KEY_DOWN] = this.movePanelDown;
        this.keyCommands[KEY_UP] = this.movePanelUp;

        this.setupEvents();
    };

    Pong.prototype = {

        keyCommands: {},

        actions: {
            update: function(params) {
                this.side = params.side;
                _.each(params.panel_positions, function(pos, i) {
                    this.panels[i].position = pos;
                }, this);
                this.render();
            },

            exception: function(type, message, backtrace) {
                console.error("Exception: " + message + " (" + type + ")");
                console.error(backtrace);
            }
        },

        height: 300,
        width: 500,
        panelHeight: 10,
        panelWidth: 50,

        panels: [
            { position: 0.0 },
            { position: 0.0 }
        ],

        render: function() {
            var context = this.canvas[0].getContext('2d');
            context.save();
            context.fillStyle = 'black';
            context.fillRect(0, 0, this.width, this.height);
            this.renderPanel(context, this.panels[0]);
            context.translate(this.width - this.panelHeight, 0);
            this.renderPanel(context, this.panels[1]);
            context.restore();
        },

        renderPanel: function(context, panel) {
            context.fillStyle = 'white';
            context.fillRect(
                0, ((this.height - this.panelWidth) * panel.position),
                this.panelHeight, this.panelWidth
            );
        },

        movePanelDown: function(evt) {
            this.sendCommand('move_panel', this.side, 'down');
        },

        movePanelUp: function(evt) {
            this.sendCommand('move_panel', this.side, 'up');
        },

        sendCommand: function() {
            var args = [];
            for(var i=1;i<arguments.length;i++) {
                args.push(arguments[i]);
            }
            var data = JSON.stringify({
                method: arguments[0],
                args: args
            });
            this.socket.send(data);
        },

        setupEvents: function() {
            $(document.body).on('keydown', _.bind(function(evt) {
                var cmd = this.keyCommands[evt.which];
                if(cmd) {
                    cmd.apply(this, [evt]);
                }
            }, this));

            this.socket.onmessage = _.bind(function(evt) {
                var message = JSON.parse(evt.data);
                console.log("Message: ", message);
                this.actions[message.method].apply(this, message.args)
            }, this);

        }

    };

    var socket = null;

    $(document).ready(function() {
        socket = new WebSocket('ws://' + document.location.host + '/socket');

        socket.onopen = function() {
            console.log("Socket open.");
            game = new Pong(socket);
        }

        socket.onclose = function() {
            console.log("Socket closed.");
        }

        socket.onmessage = function(msg) {
            console.log("Message received: " + msg);
        }
    });

})(jQuery);