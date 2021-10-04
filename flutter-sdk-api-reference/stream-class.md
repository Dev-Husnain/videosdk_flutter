# Stream Class

## using Stream Class

The `Stream Class` includes methods and events audio and video streams.

import MethodListGroup from '@theme/MethodListGroup';
import MethodListItemLabel from '@theme/MethodListItemLabel';
import MethodListHeading from '@theme/MethodListHeading';

### Properties

<MethodListGroup>
  <MethodListItemLabel name="__properties"  >
    <MethodListGroup>
      <MethodListHeading heading="Properties" />
      <MethodListItemLabel name="id" type={"String"} />
      <MethodListItemLabel name="track" type={"Consumer"} description="video | audio | share" />
      <MethodListItemLabel name="kind" type={"String?"} />
      <MethodListItemLabel name="renderer" type={"RTCVideoRenderer?"} />
    </MethodListGroup>
  </MethodListItemLabel>
</MethodListGroup>

### Methods

<MethodListGroup>
  <MethodListItemLabel name="__methods" >
    <MethodListGroup>
      <MethodListHeading heading="Methods" />
      <MethodListItemLabel type={"void"} name="pause()" />
      <MethodListItemLabel type={"void"} name="resume()" />
    </MethodListGroup>
  </MethodListItemLabel>
</MethodListGroup>

## Example

```js title="Play with Stream instance"
// pause stream
stream?.pause();

// resume stream
stream?.resume();
```
