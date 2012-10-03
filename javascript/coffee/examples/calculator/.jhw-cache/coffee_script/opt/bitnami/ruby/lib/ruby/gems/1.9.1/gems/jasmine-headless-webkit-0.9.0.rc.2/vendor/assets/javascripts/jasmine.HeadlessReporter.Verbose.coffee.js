(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  jasmine.HeadlessReporter.Verbose = (function(_super) {

    __extends(Verbose, _super);

    function Verbose() {
      this.reportException = __bind(this.reportException, this);

      this.reportSpecStarting = __bind(this.reportSpecStarting, this);

      this.colorLine = __bind(this.colorLine, this);

      this.indentLines = __bind(this.indentLines, this);

      this.indentSpec = __bind(this.indentSpec, this);

      this.displaySpec = __bind(this.displaySpec, this);

      this.displayFailure = __bind(this.displayFailure, this);

      this.displaySuccess = __bind(this.displaySuccess, this);
      return Verbose.__super__.constructor.apply(this, arguments);
    }

    Verbose.prereport = false;

    Verbose.prototype.displaySuccess = function(spec) {
      return this.displaySpec(spec, 'green');
    };

    Verbose.prototype.displayFailure = function(spec) {
      return this.displaySpec(spec, 'red');
    };

    Verbose.prototype.displaySpec = function(spec, color) {
      var currentLastNames, line, _i, _len, _ref, _results;
      currentLastNames = (this.lastNames || []).slice(0);
      this.lastNames = spec.getSpecSplitName();
      _ref = this.indentSpec(this.lastNames, currentLastNames, color);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if ((line != null) && !_.isEmpty(line)) {
          _results.push(this.puts(line));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Verbose.prototype.indentSpec = function(current, last, color) {
      var lines, name, _i, _len;
      last = last.slice(0);
      lines = [];
      for (_i = 0, _len = current.length; _i < _len; _i++) {
        name = current[_i];
        if (last.shift() !== name) {
          lines.push(name);
        } else {
          lines.push(null);
        }
      }
      return this.indentLines(lines, color);
    };

    Verbose.prototype.indentLines = function(lines, color) {
      var indent, line, output, outputLine, _i, _len;
      indent = '';
      output = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        if (line != null) {
          outputLine = indent;
          outputLine += this.colorLine(line, color);
          output.push(outputLine);
        }
        indent += '  ';
      }
      return output;
    };

    Verbose.prototype.colorLine = function(line, color) {
      return line.foreground(color);
    };

    Verbose.prototype.reportSpecStarting = function(spec) {
      if (jasmine.HeadlessReporter.Verbose.prereport) {
        return this.puts(spec.getSpecSplitName().join(' '));
      }
    };

    Verbose.prototype.reportException = function(e) {
      var output, _ref;
      e = JHW.createCoffeeScriptFileException(e);
      if (e.sourceURL && e.lineNumber) {
        output = "" + e.sourceURL + ":" + e.lineNumber + " " + e.message;
      } else {
        output = (_ref = e.message) != null ? _ref : e;
      }
      return this.puts(output.foreground('yellow'));
    };

    return Verbose;

  })(jasmine.HeadlessReporter.ConsoleBase);

}).call(this);
