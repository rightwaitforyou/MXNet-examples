format compact;
close all;
clear;
clc;

%% Add path and load library
if libisloaded('libmxnet')
    unloadlibrary('libmxnet');
end

LABELS_FILE = '../../MXNetModels/cifar1000VGGmodel/synset.txt';
MXNET_ROOT = [fileparts(mfilename('fullpath')), '/../../mxnet/'];
MXNET_LIB  = [MXNET_ROOT, '/lib'];
MXNET_SO   = [MXNET_ROOT, '/include/mxnet'];
MXNET_HDR  = 'c_predict_api.h';
addpath(MXNET_LIB);
addpath(MXNET_SO);
[err, warn] = loadlibrary('libmxnet.so', MXNET_HDR);
assert(isempty(err));

%% load the labels
labels = {};
fid = fopen(LABELS_FILE, 'r');
assert(fid >= 0);
tline = fgetl(fid);
while ischar(tline)
    labels{end+1} = tline;
    tline = fgetl(fid);
end
fclose(fid);

%% Load Symbol and Params
symblFile = '../../MXNetModels/cifar1000VGGmodel/Inception_BN-symbol.json';
paramFile = '../../MXNetModels/cifar1000VGGmodel/Inception_BN-0039.params';

%% Init object
mxObj = MXNetForwarder(symblFile, paramFile);

%% Load and resize the image
img = imread('cat_224x224x3.png');
img = single(img) - 120;

%% Forward the image
mxObj = mxObj.forward(img);

%% Retrieve output
pred = mxObj.getOutput();

%% Free object
mxObj = mxObj.free();

%% find the predict label
[pR, iD] = sort(pred, 'descend');
for i = 1:5
    fprintf('Prob=%2.3f %s\n', 100*pR(i), labels{iD(i)});
end
