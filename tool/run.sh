#!/bin/bash

echo "formatting ..."
dartfmt -w  lib/**
echo "analyzing ..."
dartanalyzer lib/trampoline.dart 

