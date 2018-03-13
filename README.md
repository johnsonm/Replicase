Replicase
=========

Replicape case in OpenSCAD

No grill is provided for the fan. It mounts to the outside of
the case, so there is no use in having an integrated grill on the
inside.  Many grill designs are available for fans, printable and
manufactured, and the user must select one with appropriate safety
for their fan and situation.

The Beaglebone with Replicape should snap into the case, and the
case should snap together.

For slicing, look at the example parameters at the end of the
replicase.gcode file. In particular, print at least the layers with
text labels at .15mm or thinner if you care that they are legible.

The most likely parameters to want to change are the fan parameters
at the top. The offset is the X and Y offset from the center of
the fan. The width of the mounting flange and the other screw
diameters are perhaps the next most likely. The rest of the
parameters are mainly for model development, and changing them may
have odd or unintended effects; the model was developed as a quick
transcription of measured and documented sizes and is substantially
over-constrained, so it is easy to specify nonsense.

Use M3 x 6mm-8mm or #4-40 x 1/4" to mount the beaglebone in the bottom
if you are not satisfied with the clips alone. Depending on your printer,
you will probably have to drill those holes out to an appropriate size.

Originally inspired by https://www.thingiverse.com/thing:2610261
but no code or shape is preserved in this model.
