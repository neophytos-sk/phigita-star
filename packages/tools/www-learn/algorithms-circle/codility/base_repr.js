            function from10(base, number) {
                if (base === 0) {
                    return "Cannot convert to base zero.";
                }
                if (Math.abs(base) === 1) {
                    if (parseInt(number) != number) {
                        return "Cannot convert non-integers in base 1 or -1.";
                    }
                    else {
                        var tallymarks = "";
                        for (var i = 0; i < Math.abs(number); i++) {
                            base === 1 ? tallymarks += "1" : tallymarks += "01";
                        }
                        if (number < 0) {
                            base === 1 ? tallymarks = "-" + tallymarks : tallymarks = tallymarks + "0";
                        }
                        return tallymarks[0] === "0" ? tallymarks.slice(1, tallymarks.length) : tallymarks;
                    }
                }
                var result = [];
                var fraction = ["."];
                var num = number;
                var to = Math.abs(base) < 1 ? 1 / base : base;
                while (Math.abs(num) > 10e-5 && fraction.length < 10) {
                    var log = logarithm(to, num);
                    num < 0 && to > 0 ? num += Math.pow(to, log) : num -= Math.pow(to, log);
                    if (log >= 0) {
                        result[log] === undefined ? result[log] = 1 : result[log] += 1;
                    }
                    else {
                        fraction[-log] === undefined ? fraction[-log] = 1 : fraction[-log] += 1;
                    }
                }
                result.reverse();
                if (to > 0 && number < 0) { result.unshift("-"); }
                result = result.concat(fraction);
                for (var index = 0; index < result.length; index++) {
                    if (!result[index]) {
                        result[index] = 0;
                    }
                    if (result[index] > 9) {
                        result[index] = parseNumbers(result[index], false) || "[" + result[index] + "]";
                    }
                }
                if (Math.abs(base) < 1) {
                    result[result.indexOf(".")] = result.splice(result.indexOf(".") - 1, 1, result[result.indexOf(".")]);
                    result.reverse();
                    if (result[result.length - 1] === "-") {
                        result.pop();
                        result.unshift("-");
                    }
                }
                return result.join("");

                function logarithm(base, num) {
                    var log = Math.floor(Math.log(Math.abs(num)) / Math.log(Math.abs(base)));
                    if (base < 0) {
                        while (1) {
                            var sum = (Math.ceil(Math.abs(base)) - 1) * (Math.pow(base, log + 2) / (base * base - 1));
                            if (Math.abs(sum) > Math.abs(num) && sum * num > 0) {
                                return log;
                            }
                            log++;
                        }
                    }
                    return log;
                }
            }


            function to10(from, num) {
                num = num.split(".");
                var integers = parseNumbers(num[0], true);
                if (num.length > 1) {
                    var floats = parseNumbers(num[1], true);
                }
                integers.reverse();
                var result = 0;
                for (var i = 0; i < integers.length; i++) {
                    result += integers[i] * Math.pow(from, i);
                }
                if (floats) {
                    for (var i = 0; i < floats.length; i++) {
                        result += floats[i] * Math.pow(from, -(i + 1));
                    }
                }
                return num[0][0] == "-" ? -result : result;
            }
