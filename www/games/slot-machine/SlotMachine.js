
var Game = (function($,document,window,undefined) {
    
    "use strict";

    var SlotMachine = function ($container) {
    
        if (!(this instanceof SlotMachine)) {
            throw "constructor called without new";
        }
    
        var uniqueId = 0;
        var $reels = $container.find(".slot-machine__reel");
        var $spinBtn = $container.find(".slot-machine__spin-btn");
        var numReels = $reels.length;
        var beverages = $container.attr("data-beverages").split(" ");
    
        function getRandomInt(min, max) {
            return Math.floor(Math.random() * (max - min + 1)) + min;
        }
    
        var SlotMachineReel = function ($root, reelOrder) {
            
            if (!(this instanceof SlotMachineReel)) {
                throw "constructor called without new";
            }
    
            var index = 0;
            var id = uniqueId++;
            var order = reelOrder;
            var self = this;
            var itemWrap = $root.find('.items');
            var originalItems = itemWrap.children();
    
            originalItems.clone().appendTo(itemWrap);
            originalItems.clone().appendTo(itemWrap);
            var items = $root.find('.items').children();
    
            var vertical = true;
            var remaining = 0;
    
            var onAnimationEnd = function () {
    
                // animation is done, reset position to save us the trouble
                // of creating new nodes
                if (index >= originalItems.length) {
                    index = index % originalItems.length;
                    seekTo(index); // no animation, reset to item
                }
    
                remaining--;
                if (remaining) {
                    rollOnce();
                } else {
    
                    getItem(index - 1).addClass('active');
                    $root.trigger('rollEnd', {
                        reelOrder: order,
                        value: getValue()
                    });
                }
    
            };
    
    
            function getValue() {
                return ((1 + items.length - index - originalItems.length) % originalItems.length);
            }
    
            function getItem(i) {
                return items.eq(items.length - i - originalItems.length);
            }
    
            function seekTo(i, time, easing) {
    
                index = i;
                var item = getItem(i);
                var props = {
                    top: -item.position().top
                };
                if (time) {
                    itemWrap.animate(props, time, easing, onAnimationEnd);
                } else {
                    itemWrap.attr('style', 'top:' + props.top + 'px');
                }
            }
    
            function rollOnce() {
                var offset, easing, time;
                if (remaining === 1) {
                    time = 300;
                    easing = 'swing';
                    offset = 1 + getRandomInt(10, 100) % originalItems.length;
                } else {
                    time = 100;
                    easing = 'linear';
                    offset = originalItems.length;
                }
    
                seekTo(index + offset, time, easing); // animate to item
            }
    
            seekTo(0);
    
            return {
                roll: function () {
                    items.removeClass("active");
                    remaining = getRandomInt(10, 20);
                    rollOnce('linear');
                }
            }
        }
    
        function allEqual(arr) {
            for (var i = 1; i < arr.length; i++) {
                if (arr[i] !== arr[i - 1]) {
                    return false;
                }
            }
            return true;
        }
    
        var checkState = function () {
            if (allEqual(state)) {
                var index = state[0];
                var beverage = beverages[index];
                $container.addClass('-winner');
                alert('You Won! Your beverage is ' + beverage);
            }
            if (window['console']) {
                console.log(state.toString());
            }
        }
    
        var state = [];
    
        var semaphore = 0;
        var onRollEnd = function (e, data) {
            var thisreel = this;
            state[data.reelOrder] = data.value;
            semaphore--;
            if (semaphore == 0) {
                checkState();
                $container.trigger('spinEnd', {
                    state: state
                });
                $spinBtn.show();
                $spinBtn.focus();
            }
        }
    
        var reels = [];
        for (var i = 0; i < numReels; i++) {
            var $root = $reels.eq(i);
            var reel = new SlotMachineReel($root, i);
            $root.on("rollEnd", onRollEnd);
            reels.push(reel);
            state[i] = 0;
        }
    
        var spin = function () {
            $container.removeClass('-winner');
            $spinBtn.hide();
            semaphore = reels.length;
            for (var i = 0; i < reels.length; i++) {
                state[i] = reels[i].roll();
            }
        };
    
        $spinBtn.hide();
        $spinBtn.on("click", spin.bind(this));
        $spinBtn.show();
        $spinBtn.focus();

    };

    return {SlotMachine:SlotMachine};    

})(jQuery,document,window);

window.onload = function(){ var slotMachine = new Game.SlotMachine($("#my-slot-machine")); };
