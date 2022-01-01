import { Flex, Section, Tabs } from "../components";
import { ButtonConfirm, ButtonInput } from "../components/Button";

const MessageModal = (props, context) => {
  const { data } = useBackend(context);
  const { maxMessageLength } = data;

  const [input, setInput] = useLocalState(context, props.label, "");

  const longEnough = props.minLength === undefined
    || input.length >= props.minLength;

  return (
    <Modal>
      <Flex direction="column">
        <Flex.Item fontSize="16px" maxWidth="90vw" mb={1}>
          {props.label}:
        </Flex.Item>

        <Flex.Item mr={2} mb={1}>
          <TextArea
            fluid
            height="20vh"
            width="80vw"
            backgroundColor="black"
            textColor="white"
            onInput={(_, value) => {
              setInput(value.substring(0, maxMessageLength));
            }}
            value={input}
          />
        </Flex.Item>

        <Flex.Item>
          <Button
            icon={props.icon}
            content={props.buttonText}
            color="good"
            disabled={!longEnough}
            tooltip={!longEnough ? "You need a longer reason." : ""}
            tooltipPosition="right"
            onClick={() => {
              if (longEnough) {
                setInput("");
                props.onSubmit(input);
              }
            }}
          />

          <Button
            icon="times"
            content="Cancel"
            color="bad"
            onClick={props.onBack}
          />
        </Flex.Item>

        {!!props.notice && (
          <Flex.Item maxWidth="90vw">{props.notice}</Flex.Item>
        )}
      </Flex>
    </Modal>
  );
};

const TabMessages = (props, context) => {
  const { act, data } = useBackend(context);
  const { messages = [] } = data;

  return (
    <Section title="Messages">
      {messages.map(message => (
        
      )}
    </Section>
  )
}

const TabMain = (props, context) => {
  const { act, data } = useBackend(context);
  const [composingBroadcast, setComposingBroadcast] = useLocalState(
    context, "composingBroadcast", false);

  const BROADCAST_TYPE = {
    generic: 0,
    emergency: 1,
  };

  return (
    <>
      <Section title="Ship Communications Console">

      </Section>

      <Section title="Transponder">
        <Flex direction="row">
          <Flex.Item>
            <ButtonConfirm
              icon="exclamation-triangle"
              color="bad"
              content="Emergency Broadcast"
              onClick={() => act("sendBroadcast", { content: "Emergency!", type: BROADCAST_TYPE.emergency })}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="bullhorn"
              content="Send Systemwide Broadcast"
              onCommit={() => setComposingBroadcast(true)}
            />
          </Flex.Item>
        </Flex>

        {composingBroadcast && (<MessageModal
          label={"Enter message to broadcast"}
          notice="Immunity to retribution brought on by inflammatory messages not included."
          icon="bullhorn"
          buttonText="Send"
          onBack={() => setComposingBroadcast(false)}
          onSubmit={message => {
            setComposingBroadcast(false);
            act("sendBroadcast", {
              content: message,
              type: BROADCAST_TYPE.generic,
            });
          }}
        />)}
      </Section>
    </>
  )
}

export const ShipCommunicationsConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {} = data;

  const [tab, setTab] = useLocalState(context, 'tab', 1);

  return (
    <Window
      width={400}
      height={650}
      resizable>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tab === 1}
            onClick={() => setTab(1)}>
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <TabMain />}
      </Window.Content>
    </Window>
  );
};
