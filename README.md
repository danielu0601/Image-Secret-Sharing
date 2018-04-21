# Image-Secret-Sharing

This is an implementation of Progressive Image Secret Sharing.

## Introduction

This work use Shamir's Secret Sharing and DCT Transform to achieve Progressive Image Secret Sharing.

## Usage

1. **Secret Sharing without Progressive**
  Use "Encrypt.m" to encrypt the secret image, i.e., seperate the image into some image shares.
  Use "Decrypt.m" to decrypt the shares into original secret image.
  See "run.m" for example.

2. **Secret Sharing with Progressive**
  Use "Encrypt_Progressive.m" and "Decrypt_Progressive.m".
  See "run_progressive.m" for example.

3. **Smaller Progressive Secret Sharing**
  Use "Encrypt_Progressive_2.m" and "Decrypt_Progressive_2.m".
  See "run_progressive_2.m" for example.
  The difference between this and previous one is that this one do the rearrange before sharing, while previous one share by a block, so the secret size can be smaller.

