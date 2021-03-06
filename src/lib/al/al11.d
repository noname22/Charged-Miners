module lib.al.al11;

import lib.loader;
import lib.al.types;

void loadAL11(Loader l)
{
	loadFunc!(alEnable)(l);
	loadFunc!(alDisable)(l);
	loadFunc!(alIsEnabled)(l);
	loadFunc!(alGetString)(l);
	loadFunc!(alGetBooleanv)(l);
	loadFunc!(alGetIntegerv)(l);
	loadFunc!(alGetFloatv)(l);
	loadFunc!(alGetDoublev)(l);
	loadFunc!(alGetBoolean)(l);
	loadFunc!(alGetInteger)(l);
	loadFunc!(alGetFloat)(l);
	loadFunc!(alGetDouble)(l);
	loadFunc!(alGetError)(l);
	loadFunc!(alIsExtensionPresent)(l);
	loadFunc!(alGetProcAddress)(l);
	loadFunc!(alGetEnumValue)(l);
	loadFunc!(alListenerf)(l);
	loadFunc!(alListener3f)(l);
	loadFunc!(alListenerfv)(l);
	loadFunc!(alListeneri)(l);
	loadFunc!(alListener3i)(l);
	loadFunc!(alListeneriv)(l);
	loadFunc!(alGetListenerf)(l);
	loadFunc!(alGetListener3f)(l);
	loadFunc!(alGetListenerfv)(l);
	loadFunc!(alGetListeneri)(l);
	loadFunc!(alGetListener3i)(l);
	loadFunc!(alGetListeneriv)(l);
	loadFunc!(alGenSources)(l);
	loadFunc!(alDeleteSources)(l);
	loadFunc!(alIsSource)(l);
	loadFunc!(alSourcef)(l);
	loadFunc!(alSource3f)(l);
	loadFunc!(alSourcefv)(l);
	loadFunc!(alSourcei)(l);
//	loadFunc!(alSource3i)(l);
//	loadFunc!(alSourceiv)(l);
	loadFunc!(alGetSourcef)(l);
	loadFunc!(alGetSource3f)(l);
	loadFunc!(alGetSourcefv)(l);
	loadFunc!(alGetSourcei)(l);
//	loadFunc!(alGetSource3i)(l);
	loadFunc!(alGetSourceiv)(l);
	loadFunc!(alSourcePlayv)(l);
	loadFunc!(alSourceStopv)(l);
	loadFunc!(alSourceRewindv)(l);
	loadFunc!(alSourcePausev)(l);
	loadFunc!(alSourcePlay)(l);
	loadFunc!(alSourceStop)(l);
	loadFunc!(alSourceRewind)(l);
	loadFunc!(alSourcePause)(l);
	loadFunc!(alSourceQueueBuffers)(l);
	loadFunc!(alSourceUnqueueBuffers)(l);
	loadFunc!(alGenBuffers)(l);
	loadFunc!(alDeleteBuffers)(l);
	loadFunc!(alIsBuffer)(l);
	loadFunc!(alBufferData)(l);
	loadFunc!(alBufferf)(l);
	loadFunc!(alBuffer3f)(l);
	loadFunc!(alBufferfv)(l);
	loadFunc!(alBufferi)(l);
	loadFunc!(alBuffer3i)(l);
	loadFunc!(alBufferiv)(l);
	loadFunc!(alGetBufferf)(l);
	loadFunc!(alGetBuffer3f)(l);
	loadFunc!(alGetBufferfv)(l);
	loadFunc!(alGetBufferi)(l);
	loadFunc!(alGetBuffer3i)(l);
	loadFunc!(alGetBufferiv)(l);
	loadFunc!(alDopplerFactor)(l);
	loadFunc!(alDopplerVelocity)(l);
	loadFunc!(alSpeedOfSound)(l);
	loadFunc!(alDistanceModel)(l);
}

const AL_NONE = 0;
const AL_FALSE = 0;
const AL_TRUE = 1;
const AL_SOURCE_RELATIVE = 0x202;
const AL_CONE_INNER_ANGLE = 0x1001;
const AL_CONE_OUTER_ANGLE = 0x1002;
const AL_PITCH = 0x1003;
const AL_POSITION = 0x1004;
const AL_DIRECTION = 0x1005;
const AL_VELOCITY = 0x1006;
const AL_LOOPING = 0x1007;
const AL_BUFFER = 0x1009;
const AL_GAIN = 0x100A;
const AL_MIN_GAIN = 0x100D;
const AL_MAX_GAIN = 0x100E;
const AL_ORIENTATION = 0x100F;
const AL_SOURCE_STATE = 0x1010;
const AL_INITIAL = 0x1011;
const AL_PLAYING = 0x1012;
const AL_PAUSED = 0x1013;
const AL_STOPPED = 0x1014;
const AL_BUFFERS_QUEUED = 0x1015;
const AL_BUFFERS_PROCESSED = 0x1016;
const AL_SEC_OFFSET = 0x1024;
const AL_SAMPLE_OFFSET = 0x1025;
const AL_BYTE_OFFSET = 0x1026;
const AL_SOURCE_TYPE = 0x1027;
const AL_STATIC = 0x1028;
const AL_STREAMING = 0x1029;
const AL_UNDETERMINED = 0x1030;
const AL_FORMAT_MONO8 = 0x1100;
const AL_FORMAT_MONO16 = 0x1101;
const AL_FORMAT_STEREO8 = 0x1102;
const AL_FORMAT_STEREO16 = 0x1103;
const AL_REFERENCE_DISTANCE = 0x1020;
const AL_ROLLOFF_FACTOR = 0x1021;
const AL_CONE_OUTER_GAIN = 0x1022;
const AL_MAX_DISTANCE = 0x1023;
const AL_FREQUENCY = 0x2001;
const AL_BITS = 0x2002;
const AL_CHANNELS = 0x2003;
const AL_SIZE = 0x2004;
const AL_UNUSED = 0x2010;
const AL_PENDING = 0x2011;
const AL_PROCESSED = 0x2012;
const AL_NO_ERROR = AL_FALSE;
const AL_INVALID_NAME = 0xA001;
const AL_INVALID_ENUM = 0xA002;
const AL_INVALID_VALUE = 0xA003;
const AL_INVALID_OPERATION = 0xA004;
const AL_OUT_OF_MEMORY = 0xA005;
const AL_VENDOR = 0xB001;
const AL_VERSION = 0xB002;
const AL_RENDERER = 0xB003;
const AL_EXTENSIONS = 0xB004;
const AL_DOPPLER_FACTOR = 0xC000;
const AL_DOPPLER_VELOCITY = 0xC001;
const AL_SPEED_OF_SOUND = 0xC003;
const AL_DISTANCE_MODEL = 0xD000;
const AL_INVERSE_DISTANCE = 0xD001;
const AL_INVERSE_DISTANCE_CLAMPED = 0xD002;
const AL_LINEAR_DISTANCE = 0xD003;
const AL_LINEAR_DISTANCE_CLAMPED = 0xD004;
const AL_EXPONENT_DISTANCE = 0xD005;
const AL_EXPONENT_DISTANCE_CLAMPED = 0xD006;

extern(C):

void (*alEnable)(ALenum capability);
void (*alDisable)(ALenum capability); 
ALboolean (*alIsEnabled)(ALenum capability); 
ALchar* (*alGetString)(ALenum param);
void (*alGetBooleanv)(ALenum param, ALboolean* data);
void (*alGetIntegerv)(ALenum param, ALint* data);
void (*alGetFloatv)(ALenum param, ALfloat* data);
void (*alGetDoublev)(ALenum param, ALdouble* data);
ALboolean (*alGetBoolean)(ALenum param);
ALint (*alGetInteger)(ALenum param);
ALfloat (*alGetFloat)(ALenum param);
ALdouble (*alGetDouble)(ALenum param);
ALenum (*alGetError)();
ALboolean (*alIsExtensionPresent)(ALchar* extname);
void* (*alGetProcAddress)(ALchar* fname);
ALenum (*alGetEnumValue)(ALchar* ename);
void (*alListenerf)(ALenum param, ALfloat value);
void (*alListener3f)(ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
void (*alListenerfv)(ALenum param, ALfloat* values); 
void (*alListeneri)(ALenum param, ALint value);
void (*alListener3i)(ALenum param, ALint value1, ALint value2, ALint value3);
void (*alListeneriv)(ALenum param, ALint* values);
void (*alGetListenerf)(ALenum param, ALfloat* value);
void (*alGetListener3f)(ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
void (*alGetListenerfv)(ALenum param, ALfloat* values);
void (*alGetListeneri)(ALenum param, ALint* value);
void (*alGetListener3i)(ALenum param, ALint *value1, ALint *value2, ALint *value3);
void (*alGetListeneriv)(ALenum param, ALint* values);
void (*alGenSources)(ALsizei n, ALuint* sources); 
void (*alDeleteSources)(ALsizei n, ALuint* sources);
ALboolean (*alIsSource)(ALuint sid); 
void (*alSourcef)(ALuint sid, ALenum param, ALfloat value); 
void (*alSource3f)(ALuint sid, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
void (*alSourcefv)(ALuint sid, ALenum param, ALfloat* values); 
void (*alSourcei)(ALuint sid, ALenum param, ALint value); 
//void (*alSource3i)(ALuint sid, ALenum param, ALint value1, ALint value2, ALint value3);
//void (*alSourceiv)(ALuint sid, ALenum param, ALint* values);
void (*alGetSourcef)(ALuint sid, ALenum param, ALfloat* value);
void (*alGetSource3f)( ALuint sid, ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3);
void (*alGetSourcefv)(ALuint sid, ALenum param, ALfloat* values);
void (*alGetSourcei)(ALuint sid,  ALenum param, ALint* value);
//void (*alGetSource3i)( ALuint sid, ALenum param, ALint* value1, ALint* value2, ALint* value3);
void (*alGetSourceiv)(ALuint sid,  ALenum param, ALint* values);
void (*alSourcePlayv)(ALsizei ns, ALuint *sids);
void (*alSourceStopv)(ALsizei ns, ALuint *sids);
void (*alSourceRewindv)(ALsizei ns, ALuint *sids);
void (*alSourcePausev)(ALsizei ns, ALuint *sids);
void (*alSourcePlay)(ALuint sid);
void (*alSourceStop)(ALuint sid);
void (*alSourceRewind)(ALuint sid);
void (*alSourcePause)(ALuint sid);
void (*alSourceQueueBuffers)(ALuint sid, ALsizei numEntries, ALuint *bids);
void (*alSourceUnqueueBuffers)(ALuint sid, ALsizei numEntries, ALuint *bids);
void (*alGenBuffers)(ALsizei n, ALuint* buffers);
void (*alDeleteBuffers)(ALsizei n, ALuint* buffers);
ALboolean (*alIsBuffer)(ALuint bid);
void (*alBufferData)(ALuint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq);
void (*alBufferf)(ALuint bid, ALenum param, ALfloat value);
void (*alBuffer3f)(ALuint bid, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
void (*alBufferfv)(ALuint bid, ALenum param, ALfloat* values);
void (*alBufferi)(ALuint bid, ALenum param, ALint value);
void (*alBuffer3i)(ALuint bid, ALenum param, ALint value1, ALint value2, ALint value3);
void (*alBufferiv)(ALuint bid, ALenum param, ALint* values);
void (*alGetBufferf)(ALuint bid, ALenum param, ALfloat* value);
void (*alGetBuffer3f)(ALuint bid, ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3);
void (*alGetBufferfv)(ALuint bid, ALenum param, ALfloat* values);
void (*alGetBufferi)(ALuint bid, ALenum param, ALint* value);
void (*alGetBuffer3i)(ALuint bid, ALenum param, ALint* value1, ALint* value2, ALint* value3);
void (*alGetBufferiv)(ALuint bid, ALenum param, ALint* values);
void (*alDopplerFactor)(ALfloat value);
void (*alDopplerVelocity)(ALfloat value);
void (*alSpeedOfSound)(ALfloat value);
void (*alDistanceModel)(ALenum distanceModel);
